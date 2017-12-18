"
I am a Socket that knows about the dangers of remaining open across snapshot.
"
Class {
	#name : #SafeSocket,
	#superclass : #Socket,
	#instVars : [
		'hostName'
	],
	#classVars : [
		'InstanceList'
	],
	#category : #'Communications-Endpoints'
}

{ #category : #'class initialization' }
SafeSocket class >> initialize [
	"SafeSocket initialize"

	InstanceList := IdentitySet new.
	Smalltalk
		addToStartUpList: self;
		addToShutDownList: self.
]

{ #category : #'instance creation' }
SafeSocket class >> new [

	^InstanceList add: super new
]

{ #category : #snapshot }
SafeSocket class >> shutDown: quitting [
	"We're about to snapshot and quit: shut down any open connections."

	InstanceList := InstanceList select: [ :sock | sock isConnected].
	(quitting and: [InstanceList notEmpty]) ifTrue:
		[(self confirm: (String streamContents: [ :str |
				str nextPutAll: 'Open network connections exist to the following hosts:'.
				InstanceList do: [ :sock | str cr; tab; nextPutAll: sock name].
				str cr; nextPutAll: 'Do you want to shut them down before quitting?']))
			ifTrue: [InstanceList do: [:sock | sock close]]]
]

{ #category : #snapshot }
SafeSocket class >> startUp: resuming [
	"We're coming back from snapshot and quit.  Close any connections that were left open in the snapshot."

	(resuming and: [InstanceList notEmpty])
		ifTrue: [InstanceList do: [ :sock | sock close]]
]

{ #category : #'initialize-release' }
SafeSocket >> close [

	super close.
	InstanceList remove: self ifAbsent: []
]

{ #category : #'initialize-release' }
SafeSocket >> connectTo: host port: port [

	hostName := host.
	^super connectTo: hostName port: port
]

{ #category : #accessing }
SafeSocket >> name [
	"Answer the name of the peer."

	^self isConnected
		ifTrue: [hostName isNil ifTrue: [NetNameResolver stringFromAddress: self remoteAddress] ifFalse: [hostName]]
		ifFalse: ['not connected']
]

{ #category : #accessing }
SafeSocket >> name: aString [
	"Set the name of the connection."

	hostName := aString
]

{ #category : #primitives }
SafeSocket >> primSocketCloseConnection: socketID [
	"Close the connection on the given port. The remote end is informed that this end has closed and will do no further sends. This is an asynchronous call; query the socket status to discover if and when the connection is actually closed.  Overriden to avoid primitive fail error in superclass."

	<primitive: 'primitiveSocketCloseConnection' module: 'SocketPlugin'>
]

{ #category : #primitives }
SafeSocket >> primSocketReceiveDataAvailable: socketID [
	"Return true if data may be available for reading from the current socket.  Overridden to avoid primitive failure when the socket is closed asynchronously (or left open across snapshot and quit)."

	<primitive: 'primitiveSocketReceiveDataAvailable' module: 'SocketPlugin'>
	^false
]
