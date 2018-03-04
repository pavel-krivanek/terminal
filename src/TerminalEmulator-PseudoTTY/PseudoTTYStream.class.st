"
I am a very particular stream connected to the `master' half of a pseudo TTY (pty).  My purpose in life is to provide communication with a process (in the fork+exec sense) that is connected to the `slave' half of the pty.  (Writing to a master pty causes the data to appear on the slave's stdin, and anything written to the slave's stdout/stderr is available for subsequent reading on the master pty.)

You create me by sending my class

	command: programNameString arguments: arrayOfArgumentStrings

Note also that I am really intended to be used by a ProcessEndpoint as part of a ProtocolStack (along with a terminal emulator and a TeletypeMorph to provide interaction with the subprocess).

"
Class {
	#name : #PseudoTTYStream,
	#superclass : #Object,
	#instVars : [
		'terminal'
	],
	#category : #'TerminalEmulator-PseudoTTY'
}

{ #category : #'as yet unclassified' }
PseudoTTYStream class >> command: commandString arguments: argumentArray [

	^ self new command: commandString arguments: argumentArray

]

{ #category : #'input/output' }
PseudoTTYStream >> close [
	
	terminal close.
]

{ #category : #'input/output' }
PseudoTTYStream >> command: commandString arguments: argumentArray [

	terminal := PseudoTTY new.
	terminal spawn: {commandString. argumentArray first}.
]

{ #category : #'input/output' }
PseudoTTYStream >> isConnected [

	^ terminal isOpen
]

{ #category : #'input/output' }
PseudoTTYStream >> nextPut: aCharacterOrInteger [
	
	^ terminal nextPut: aCharacterOrInteger
]

{ #category : #'input/output' }
PseudoTTYStream >> noteWindowSize: aPoint [
	"PseudoTTYLib uniqueInstance
		setWindowSizeFor: (master unsignedLongAt: 1) value
		cols: aPoint x
		rows: aPoint y"
		
"int setWindowSize(int fd, int cols, int rows)
{/*
#if defined(TIOCSWINSZ)
  struct winsize sz;
  sz.ws_col= cols;
  sz.ws_row= rows;
  sz.ws_xpixel= sz.ws_ypixel= 0;
  if (ioctl(fd, TIOCSWINSZ, &sz) == -1)
    return 1;
#endif
  return 0;
  */
}"
]

{ #category : #'input/output' }
PseudoTTYStream >> peekUpToEnd [
	^ ((terminal next: 3000) utf8Decoded) asArray collect: [:each | each asciiValue].
]
