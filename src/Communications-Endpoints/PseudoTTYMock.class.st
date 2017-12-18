"
win := TeletypeWindow open.
	(ProcessEndpoint command: '' arguments: '') asProtocolStack
		push:		VT102Emulator new;
		push:		(win instVarNamed: #tty);
		install;
		run
"
Class {
	#name : #PseudoTTYMock,
	#superclass : #Object,
	#instVars : [
		'stream'
	],
	#category : #'Communications-Endpoints'
}

{ #category : #'as yet unclassified' }
PseudoTTYMock class >> command: commandString arguments: argumentArray [

	^ self new
]

{ #category : #'input/output' }
PseudoTTYMock >> initialize [

	super initialize.
	
	stream := 'htop-out.txt' asFileReference readStream.
	
	
]

{ #category : #'input/output' }
PseudoTTYMock >> isConnected [

	^ true
]

{ #category : #'input/output' }
PseudoTTYMock >> noteWindowSize: aPoint [

	"self primWindowSize: fileHandle cols: aPoint x rows: aPoint y"
]

{ #category : #'input/output' }
PseudoTTYMock >> peekUpToEnd [

	^ stream upToEnd asByteArray.
]
