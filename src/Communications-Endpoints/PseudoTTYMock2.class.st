Class {
	#name : #PseudoTTYMock2,
	#superclass : #Object,
	#instVars : [
		'master',
		'slave'
	],
	#category : #'Communications-Endpoints'
}

{ #category : #'as yet unclassified' }
PseudoTTYMock2 class >> command: commandString arguments: argumentArray [

	^ self new
]

{ #category : #'input/output' }
PseudoTTYMock2 >> initialize [

	super initialize.
	
FFIMethodRegistry resetAll.
Smalltalk vm listLoadedModules.
Smalltalk vm unloadModule: 'pty.so'.
Smalltalk garbageCollect.

LibC uniqueInstance system: 'gcc -c -m32 pty.c'.
LibC uniqueInstance system: 'gcc -shared -m32 -o pty.so pty.o -lutil '.

master := LGitWriteBackValueInt new.
slave := LGitWriteBackValueInt new.
	
PseudoTTYLib uniqueInstance	openMaster: master slave: slave.
	
]

{ #category : #'input/output' }
PseudoTTYMock2 >> isConnected [

	^ true
]

{ #category : #'input/output' }
PseudoTTYMock2 >> nextPut: aCharacterOrInteger [

	| buffer |
	
	
	buffer := {aCharacterOrInteger} asByteArray.
	buffer pinInMemory.

	^ PseudoTTYLib uniqueInstance write: master to: buffer length: buffer size.
	
	
	

]

{ #category : #'input/output' }
PseudoTTYMock2 >> noteWindowSize: aPoint [

	PseudoTTYLib uniqueInstance setWindowSizeFor: master value cols: aPoint x rows: aPoint y
	
	

]

{ #category : #'input/output' }
PseudoTTYMock2 >> peekUpToEnd [

	| buffer length |
	
	buffer := ByteArray ofSize: 32.
	buffer pinInMemory.
	PTTYResourceChecker waitFor: master value.

	length := PseudoTTYLib uniqueInstance read: master to: buffer maxLength: buffer size.
	
	^ buffer first: length.
	

]
