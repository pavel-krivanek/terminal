"
I am a very particular kind of AsyncFile connected to the `master' half of a pseudo TTY (pty).  My purpose in life is to provide communication with a process (in the fork+exec sense) that is connected to the `slave' half of the pty.  (Writing to a master pty causes the data to appear on the slave's stdin, and anything written to the slave's stdout/stderr is available for subsequent reading on the master pty.)

You create me by sending my class

	command: programNameString arguments: arrayOfArgumentStrings

which will spawn a new process running the named program with the given arguments.  You can subsequently send me #nextPut: (or #nextPutAll:) to send stuff to the stdin of the program, and #upToEnd to retrieve data that the program writes to its stdout or stderr.  You can also send me #close which will shut down the program (by sending it SIGTERM followed shortly thereafter by SIGKILL if it's being stubborn) and both halves of the pseudo tty.

The spawned program runs in a new session, will be its own session and process group leader and will have the slave half of the pty as its controlling terminal.  (In plain English this means that the program will behave exactly as if it were being run from login, in particular: shells will enable job control, screen-oriented programs like Emacs will work properly, the user's login tmode settings will be inherited, intr/quit/etc. characters will be cooked into the corresponding signals, and window geometry changes will be propagated to the program.  Neat, huh? ;-)

Note that you need both the AsynchFile and PseudoTTY plugins in order for any of this to work.

Note also that I am really intended to be used by a ProcessEndpoint as part of a ProtocolStack (along with a terminal emulator and a TeletypeMorph to provide interaction with the subprocess).

"
Class {
	#name : #PseudoTTY,
	#superclass : #AsyncFile,
	#instVars : [
		'inputBuffer',
		'outputBuffer',
		'ioError'
	],
	#classVars : [
		'AsyncFileError',
		'InstanceList'
	],
	#category : #'Communications-Endpoints'
}

{ #category : #'instance creation' }
PseudoTTY class >> command: commandString arguments: argumentArray [

	"(PseudoTTY command: '/bin/bash' arguments: #('-c' 'pwd')) upToEnd asString"

	| pty |
	pty := self new
		command: commandString
		arguments: argumentArray.
	pty isNil ifFalse: [InstanceList add: pty].
	^pty
]

{ #category : #examples }
PseudoTTY class >> example [
	"Show the user's current tty mode settings."
	"PseudoTTY example"

	| pty output buf |
	pty := self command: '/bin/stty' arguments: #('-a').
	pty isNil ifTrue: [^self error: 'Could not create pty or process.'].
	output := WriteStream on: String new.
	output nextPutAll: 'Your tty modes are: '; cr; space; cr.
	[(buf := pty upToEnd) isNil] whileFalse: [output nextPutAll: buf asString].
	pty close.
	self inform: output contents
]

{ #category : #'class initialization' }
PseudoTTY class >> initialize [
	"PseudoTTY initialize"

	"Can't rely on Error because the compiler finds the global before the class var.  Ho hum."
	AsyncFileError := -2.

	InstanceList := IdentitySet new.
	Smalltalk
		addToStartUpList: self;
		addToShutDownList: self.
]

{ #category : #snapshot }
PseudoTTY class >> shutDown: quitting [
	"We're about to snapshot: shut down any open connections."

	quitting ifTrue: [InstanceList do: [:ep | ep close]]
]

{ #category : #snapshot }
PseudoTTY class >> startUp: resuming [
	"We're coming back from snapshot.  Close any connections that were left open in the snapshot."

	resuming ifTrue: [InstanceList do: [:ep | ep close]]
]

{ #category : #'initialize-release' }
PseudoTTY >> close [
	"Close the master half of the pty.  The subprocess should exit (EOF on stdin) although badly written programs might start looping."

	fileHandle isNil ifTrue: [^self].
	self primClosePts: fileHandle.
	fileHandle := nil.
	Smalltalk unregisterExternalObject: semaphore.
	ioError := AsyncFileError.
	semaphore signal.	"wake up waiters"
	semaphore := nil.
	InstanceList remove: self ifAbsent: []
]

{ #category : #'initialize-release' }
PseudoTTY >> command: programName arguments: argumentArray [
	"Create a pseudo tty and then spawn programName with its stdin, out and err connected to the slave end of the pty."

	| semaIndex |
	"AsyncFile"
	name := programName.
	writeable := true.
	semaphore := Semaphore new.
	semaIndex := Smalltalk registerExternalObject: semaphore.
	"PseudoTTY"
	inputBuffer := ByteArray new: 8192.
	outputBuffer := ByteArray new: 1.
	ioError := 0.
	fileHandle := self
		forkAndExecWithPts: programName
		arguments: (argumentArray isNil
			ifTrue: [#()]
			ifFalse: [argumentArray])
		semaIndex: semaIndex.
	fileHandle isNil ifTrue: [
		Smalltalk unregisterExternalObject: semaphore.
		semaphore := nil.
		ioError := AsyncFileError.
		^nil].
	Processor yield.
	semaphore signal.
	^self
]

{ #category : #private }
PseudoTTY >> forkAndExecWithPts: aCommand arguments: argArray semaIndex: semaIndex [
	"Run aCommand as an inferior process and connect its std{in,out,err} to the receiver through a pseudo tty."

	^self primForkAndExec: aCommand arguments: argArray semaIndex: semaIndex
]

{ #category : #'input/output' }
PseudoTTY >> ioError [
	"Return the last error code received during read/write.  If this is ever non-zero it means the subprocess has probably died."

	^ioError
]

{ #category : #'input/output' }
PseudoTTY >> isConnected [

	^fileHandle notNil and: [ioError == 0]
]

{ #category : #accessing }
PseudoTTY >> name [
	"Answer the name of the program."

	^name
]

{ #category : #'input/output' }
PseudoTTY >> nextPut: aCharacterOrInteger [
	"Send a single character to the stdin of my subprocess."

	fileHandle isNil ifTrue: [^self].
	outputBuffer at: 1 put: aCharacterOrInteger asInteger.
	self
		primWriteStart: fileHandle
		fPosition: -1
		fromBuffer: outputBuffer
		at: 1
		count: 1
]

{ #category : #'input/output' }
PseudoTTY >> nextPutAll: aStringOrByteArray [
	"Send an entire string to the stdin of my subprocess."

	fileHandle isNil ifTrue: [^self].
	self
		primWriteStart: fileHandle
		fPosition: -1
		fromBuffer: aStringOrByteArray
		at: 1
		count: aStringOrByteArray size
]

{ #category : #'input/output' }
PseudoTTY >> noteWindowSize: aPoint [

	self primWindowSize: fileHandle cols: aPoint x rows: aPoint y
]

{ #category : #'input/output' }
PseudoTTY >> peekUpToEnd [
	"Answer everything the subprocess has written to stdout or stderr since the last send of #upToEnd.  Note that stuff written to stderr might arrive earlier than stuff written to stdout if the former is unbuffered and the latter line buffered in the subprocess's stdio library."

	| n |
	self isConnected ifFalse: [^nil].
	n := self
			primReadResult: fileHandle
			intoBuffer: inputBuffer
			at: 1
			count: inputBuffer size.
	^(self isConnected and: [n > 0])
		ifTrue: [inputBuffer copyFrom: 1 to: n]
		ifFalse: [nil]
]

{ #category : #primitives }
PseudoTTY >> primClosePts: fHandle [
	"Kill the process whose pts is associated with our pty."

	<primitive: 'primPtyClose' module: 'PseudoTTYPlugin'>
	^nil
]

{ #category : #primitives }
PseudoTTY >> primForkAndExec: command arguments: arguments semaIndex: semaIndex [
	"Fork and exec command with the given arguments connecting the new process to a slave tty created from the receiver (which is the master half of a pseudo tty)."

	<primitive: 'primPtyForkAndExec' module: 'PseudoTTYPlugin'>
	^nil
]

{ #category : #primitives }
PseudoTTY >> primWindowSize: fHandle cols: cols rows: rows [
	"Set the size of the terminal connected to the pty."

	<primitive: 'primPtyWindowSize' module: 'PseudoTTYPlugin'>
	^nil
]

{ #category : #private }
PseudoTTY >> startRead: count [
	"Indicate interest in receiving more data from stdout/stderr of the subprocess."

	self
		primReadStart: fileHandle
		fPosition: -1
		count: count
]

{ #category : #'input/output' }
PseudoTTY >> upToEnd [
	"Answer everything the subprocess has written to stdout or stderr since the last send of #upToEnd.  Note that stuff written to stderr might arrive earlier than stuff written to stdout if the former is unbuffered and the latter line buffered in the subprocess's stdio library."

	| n |
	[self isConnected and: [(n := self startRead: inputBuffer size;
			primReadResult: fileHandle
			intoBuffer: inputBuffer
			at: 1
			count: inputBuffer size) == Busy]]
		whileTrue: [self waitForCompletion].
	(self isConnected and: [n > 0])
		ifTrue: [^inputBuffer copyFrom: 1 to: n]
		ifFalse: [ioError := AsyncFileError.  ^nil]		"subprocess has died or closed stdout"
]
