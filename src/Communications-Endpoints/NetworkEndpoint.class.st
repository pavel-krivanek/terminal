"
I am an endpoint for network communication.  I am also a ProtocolLayer and I therefore expect to be inserted as the lowest element in a LayeredProtocol stack.

Structure:

	socket			(Socket)	-- the socket on which I communicate.

"
Class {
	#name : #NetworkEndpoint,
	#superclass : #ProtocolEndpoint,
	#instVars : [
		'socket'
	],
	#classVars : [
		'InstanceList'
	],
	#category : #'Communications-Endpoints'
}

{ #category : #examples }
NetworkEndpoint class >> example [
	"NetworkEndpoint example"

	^NetworkEndpoint new
		socket: ((Socket initializeNetwork; new)
					connectTo: (NetNameResolver addressForName: 'localhost') port: 13;
					waitForConnectionUntil: (Socket deadlineSecs: 1);
					yourself);
		up: (ProtocolAdaptor new
				upBlock: [:arg | Transcript nextPut: arg asCharacter; endEntry]);
		run.
]

{ #category : #examples }
NetworkEndpoint class >> example2 [
	"NetworkEndpoint example2"

	| s |
	NetworkEndpoint new
		socket: ((s := Socket initializeNetwork; new)
					connectTo: (NetNameResolver addressForName: 'localhost') port: 7;
					waitForConnectionUntil: (Socket deadlineSecs: 1);
					yourself);
		up: (ProtocolAdaptor new
				upBlock: [:arg | Transcript nextPut: arg asCharacter; endEntry]);
		run.
	s sendData: 'send this back to me'.
	(Delay forSeconds: 1) wait.
	s close
]

{ #category : #examples }
NetworkEndpoint class >> example3 [
	"NetworkEndpoint example3"

	| ep |
	(ep := NetworkEndpoint newConnection: 'localhost' port: 7)
		up: (ProtocolAdaptor upBlock:
				[:arg | Transcript nextPut: arg asCharacter; endEntry]);
		run.
	ep socket sendData: 'send this back to me'.
	(Delay forSeconds: 1) wait.
	ep socket close
]

{ #category : #examples }
NetworkEndpoint class >> newConnection: host port: port [

	| s addr |
	Socket initializeNetwork.
	(addr := NetNameResolver addressForName: host) isNil
		ifTrue: [^nil].
	(s := SafeSocket new)
		connectTo: addr port: port;
		waitForConnectionUntil: Socket standardDeadline.
	s isWaitingForConnection
		ifTrue: [s destroy. ^nil].
	s name: host.
	^self new socket: s
]

{ #category : #'initialize-release' }
NetworkEndpoint >> close [

	socket notNil ifTrue: [socket close]
]

{ #category : #'protocol stack' }
NetworkEndpoint >> downcall: char [

	socket isConnected
		ifTrue: [socket sendData: (ByteArray with: char)]
		ifFalse: [socket closeAndDestroy]
]

{ #category : #'protocol stack' }
NetworkEndpoint >> downcallAll: collection [
	"This is just for speed in telnet negotiation."

	socket isConnected
		ifTrue: [socket sendData: collection]
		ifFalse: [socket closeAndDestroy]
]

{ #category : #accessing }
NetworkEndpoint >> getData [

	| buf count |
	Processor yield.
	buf := ByteArray new: 1024.
	[socket dataAvailable
		ifTrue:
			[count := socket receiveDataInto: buf.
			 ^buf copyFrom: 1 to: count]
		ifFalse:
			[up flush.
			 socket waitForDataUntil: (Socket deadlineSecs: 1)].
	 socket isConnected]
		whileTrue.
	^nil
]

{ #category : #accessing }
NetworkEndpoint >> isConnected [

	^socket notNil and: [socket isConnected]
]

{ #category : #accessing }
NetworkEndpoint >> name [
	"Answer the name of the peer."

	(socket isNil or: [socket isConnected not])
		ifTrue: [^'not connected'].
	^NetNameResolver stringFromAddress: socket remoteAddress
]

{ #category : #'protocol stack' }
NetworkEndpoint >> note: aSymbol with: anObject [

	super note: aSymbol with: anObject.
	aSymbol == #connectedTo		ifTrue: [^self ttyMsgCR: 'Connected to ', anObject, '.'].
	aSymbol == #endpointClosed		ifTrue: [^self ttyCR; ttyMsgCR: 'Connection closed.'].
	aSymbol == #oobInlineEndpoint	ifTrue: [^socket setOption: 'SO:=OOBINLINE' value: 1].
	aSymbol == #savePreferences		ifTrue: [^self savePreferences: anObject].
]

{ #category : #debugging }
NetworkEndpoint >> rcvd: char [

	| str |
	str := char asInteger printStringBase: 16.
	str := str copyFrom: 4 to: str size.
	Transcript cr; nextPut: $<; tab; nextPutAll: (str padded: #left to: 2 with: $0); tab; nextPut: char asCharacter
]

{ #category : #'protocol stack' }
NetworkEndpoint >> run [

	self isConnected ifTrue: [self sessionNote: #connectedTo with: self name].
	super run
]

{ #category : #private }
NetworkEndpoint >> savePreferences: dict [

	dict at: #endpointClass put: self class name.
	dict at: #endpointCreate put: #newConnection:port:.
	dict at: #endpointArguments put: (Array with: socket name with: socket remotePort)
]

{ #category : #debugging }
NetworkEndpoint >> sent: char [

	| str |
	str := char asInteger printStringBase: 16.
	str := str copyFrom: 4 to: str size.
	Transcript cr; nextPut: $>; tab; nextPutAll: (str padded: #left to: 2 with: $0); tab; nextPut: char asCharacter
]

{ #category : #accessing }
NetworkEndpoint >> socket [

	^socket
]

{ #category : #'initialize-release' }
NetworkEndpoint >> socket: aSocket [

	socket := aSocket
]
