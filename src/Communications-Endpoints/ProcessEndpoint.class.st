"
I am an endpoint for communication with another process.  I am also a ProtocolLayer and I therefore expect to be inserted as the lowest element in a LayeredProtocol stack.

Well, that's the official story anyway.  In fact I am happy to communicate with anything that talks through an AsyncFile.  It just so happens that one kind of AsyncFile is PsuedoTTY which can be connected to the stdin, stdout and stderr of a remote process.

Structure:

	pty			(PseudoTTY)	-- the asynchronous file with which I communicate.

"
Class {
	#name : #ProcessEndpoint,
	#superclass : #ProtocolEndpoint,
	#instVars : [
		'pty',
		'command',
		'arguments'
	],
	#category : #'Communications-Endpoints'
}

{ #category : #'instance creation' }
ProcessEndpoint class >> command: command [

	^self command: command arguments: nil
]

{ #category : #'instance creation' }
ProcessEndpoint class >> command: command arguments: arguments [

	^self new command: command arguments: arguments
]

{ #category : #'instance creation' }
ProcessEndpoint class >> example [
	"ProcessEndpoint example upToEnd asString"

	^ProcessEndpoint command: '/bin/bash' arguments: #('-ec' '/bin/pwd')
]

{ #category : #'instance creation' }
ProcessEndpoint class >> example2 [
	"ProcessEndpoint example2"

	| tty |
	^LayeredProtocol new
		addDown: (tty := TeletypeMorph open);
		addDown: (XtermEmulator new window: tty);
		addDown: (ProcessEndpoint command: '/bin/bash' arguments: #('-i'));
		install;
		run
]

{ #category : #'instance creation' }
ProcessEndpoint class >> example3 [
	"ProcessEndpoint example3"

	^(LayeredProtocol
		on:		(ProcessEndpoint command: '/bin/bash' arguments: #('-i')))
		push:	XtermEmulator new;
		push:	TeletypeMorph open;
		install;
		run
]

{ #category : #protocol }
ProcessEndpoint >> close [

	pty close.
]

{ #category : #'initialize-release' }
ProcessEndpoint >> command: cmd arguments: args [

	(pty := PseudoTTYMock2 command: cmd arguments: args)
		isNil ifTrue: [^self error: 'could not create process'].
	command := cmd.
	arguments := args.
]

{ #category : #protocol }
ProcessEndpoint >> downcall: char [

	pty nextPut: char
]

{ #category : #'server loop' }
ProcessEndpoint >> getData [
	"Answer the next chunk of stuff from the pty or nil if the pty has been closed."

	| buf |
	pty isConnected ifFalse: [^nil].
	Processor yield.
	(buf := pty peekUpToEnd) isNil ifTrue: [up flush.  buf := pty upToEnd].
	^buf
]

{ #category : #protocol }
ProcessEndpoint >> isConnected [

	^pty isConnected
]

{ #category : #protocol }
ProcessEndpoint >> name [

	^pty name
]

{ #category : #protocol }
ProcessEndpoint >> note: aSymbol with: anObject [

	super note: aSymbol with: anObject.
	aSymbol == #windowSize		ifTrue: [^pty noteWindowSize: anObject "Point"].
	aSymbol == #endpointClosed	ifTrue: [^self ttyCR; ttyMsgCR: 'Process terminated.'].
	aSymbol == #savePreferences	ifTrue: [^self savePreferences: anObject]
]

{ #category : #private }
ProcessEndpoint >> savePreferences: dict [

	dict
		at: #endpointClass put: self class name;
		at: #endpointCreate put: #command:arguments:;
		at: #endpointArguments put: (Array with: command with: arguments)
]
