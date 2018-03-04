"
I am an endpoint for communication with another process.  I am also a ProtocolLayer and I therefore expect to be inserted as the lowest element in a LayeredProtocol stack.

Well, that's the official story anyway.  In fact I am happy to communicate with anything that talks through an AsyncFile.  It just so happens that one kind of AsyncFile is PsuedoTTY which can be connected to the stdin, stdout and stderr of a remote process.

Structure:

	pty			(PseudoTTY)	-- the asynchronous file with which I communicate.

"
Class {
	#name : #PseudoTTYEndpoint,
	#superclass : #ProtocolEndpoint,
	#instVars : [
		'pty',
		'command',
		'arguments'
	],
	#category : #'TerminalEmulator-PseudoTTY'
}

{ #category : #'instance creation' }
PseudoTTYEndpoint class >> command: command [

	^self command: command arguments: nil
]

{ #category : #'instance creation' }
PseudoTTYEndpoint class >> command: command arguments: arguments [

	^self new command: command arguments: arguments
]

{ #category : #'instance creation' }
PseudoTTYEndpoint class >> example [
	"ProcessEndpoint example upToEnd asString"

	^PseudoTTYEndpoint command: '/bin/bash' arguments: #('-ec' '/bin/pwd')
]

{ #category : #'instance creation' }
PseudoTTYEndpoint class >> example2 [
	"ProcessEndpoint example2"

	| tty |
	^LayeredProtocol new
		addDown: (tty := TerminalEmulatorMorph open);
		addDown: (TerminalEmulatorXterm new window: tty);
		addDown: (PseudoTTYEndpoint command: '/bin/bash' arguments: #('-i'));
		install;
		run
]

{ #category : #'instance creation' }
PseudoTTYEndpoint class >> example3 [
	"ProcessEndpoint example3"

	^(LayeredProtocol
		on:		(PseudoTTYEndpoint command: '/bin/bash' arguments: #('-i')))
		push:	TerminalEmulatorXterm new;
		push:	TerminalEmulatorMorph open;
		install;
		run
]

{ #category : #protocol }
PseudoTTYEndpoint >> close [

	pty close.
]

{ #category : #'initialize-release' }
PseudoTTYEndpoint >> command: cmd arguments: args [

	(pty := PseudoTTYStream command: cmd arguments: args)
		isNil ifTrue: [^self error: 'could not create process'].
	command := cmd.
	arguments := args.
]

{ #category : #protocol }
PseudoTTYEndpoint >> downcall: char [

	pty nextPut: char
]

{ #category : #'server loop' }
PseudoTTYEndpoint >> getData [
	"Answer the next chunk of stuff from the pty or nil if the pty has been closed."

	| buf |
	pty isConnected ifFalse: [^nil].
	Processor yield.
	(buf := pty peekUpToEnd) isNil ifTrue: [up flush.  buf := pty upToEnd].
	^buf
]

{ #category : #protocol }
PseudoTTYEndpoint >> isConnected [

	^pty isConnected
]

{ #category : #protocol }
PseudoTTYEndpoint >> name [

	^pty name
]

{ #category : #protocol }
PseudoTTYEndpoint >> note: aSymbol with: anObject [

	super note: aSymbol with: anObject.
	aSymbol == #windowSize		ifTrue: [^pty noteWindowSize: anObject "Point"].
	aSymbol == #endpointClosed	ifTrue: [^self ttyCR; ttyMsgCR: 'Process terminated.'].
	aSymbol == #savePreferences	ifTrue: [^self savePreferences: anObject]
]

{ #category : #private }
PseudoTTYEndpoint >> savePreferences: dict [

	dict
		at: #endpointClass put: self class name;
		at: #endpointCreate put: #command:arguments:;
		at: #endpointArguments put: (Array with: command with: arguments)
]
