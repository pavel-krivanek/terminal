"
win := TeletypeWindow open.
(ProcessEndpoint command: '/bin/bash' arguments: {'-i'}) asProtocolStack
	push:        TerminalEmulatorXterm new;
	push:        win tty;
	install;
	run
"
Class {
	#name : #PseudoTTYStreamMock,
	#superclass : #Object,
	#instVars : [
		'stream'
	],
	#category : #'TerminalEmulator-Tests'
}

{ #category : #'as yet unclassified' }
PseudoTTYStreamMock class >> command: commandString arguments: argumentArray [

	^ self new
]

{ #category : #'input/output' }
PseudoTTYStreamMock >> initialize [

	super initialize.
	
	stream := 'htop-out.txt' asFileReference readStream.
	
	
]

{ #category : #'input/output' }
PseudoTTYStreamMock >> isConnected [

	^ true
]

{ #category : #'input/output' }
PseudoTTYStreamMock >> noteWindowSize: aPoint [

	"self primWindowSize: fileHandle cols: aPoint x rows: aPoint y"
]

{ #category : #'input/output' }
PseudoTTYStreamMock >> peekUpToEnd [

	^ stream upToEnd asByteArray.
]
