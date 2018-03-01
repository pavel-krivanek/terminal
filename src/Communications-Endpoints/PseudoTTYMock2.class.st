Class {
	#name : #PseudoTTYMock2,
	#superclass : #Object,
	#instVars : [
		'terminal'
	],
	#category : #'Communications-Endpoints'
}

{ #category : #'as yet unclassified' }
PseudoTTYMock2 class >> command: commandString arguments: argumentArray [

	^ self new
]

{ #category : #'input/output' }
PseudoTTYMock2 >> close [
	
	terminal close.
]

{ #category : #'input/output' }
PseudoTTYMock2 >> initialize [

	super initialize.
	terminal := PseudoTerminal new.
	terminal spawn: {'/bin/bash'. '-i'}.
]

{ #category : #'input/output' }
PseudoTTYMock2 >> isConnected [

	^ terminal isOpen
]

{ #category : #'input/output' }
PseudoTTYMock2 >> nextPut: aCharacterOrInteger [
	
	^ terminal nextPut: aCharacterOrInteger
]

{ #category : #'input/output' }
PseudoTTYMock2 >> noteWindowSize: aPoint [
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
PseudoTTYMock2 >> peekUpToEnd [
	^ terminal next: 3000.
]
