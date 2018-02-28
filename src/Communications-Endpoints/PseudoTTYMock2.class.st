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

"LibC uniqueInstance system: 'gcc -c -m32 pty.c'.
LibC uniqueInstance system: 'gcc -shared -m32 -o pty.so pty.o -lutil '.
"
master := (FFIExternalType resolveType: 'int') newBuffer.
slave := (FFIExternalType resolveType: 'int') newBuffer.
	
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
	^ PseudoTTYLib uniqueInstance write: (master unsignedLongAt: 1) to: buffer length: buffer size
]

{ #category : #'input/output' }
PseudoTTYMock2 >> noteWindowSize: aPoint [
	PseudoTTYLib uniqueInstance
		setWindowSizeFor: (master unsignedLongAt: 1) value
		cols: aPoint x
		rows: aPoint y
]

{ #category : #'input/output' }
PseudoTTYMock2 >> peekUpToEnd [
	| buffer length |
	buffer := ByteArray ofSize: 32.
	buffer pinInMemory.
	PTTYResourceChecker waitFor: (master unsignedLongAt: 1).
	length := PseudoTTYLib uniqueInstance
		read: (master unsignedLongAt: 1)
		to: buffer
		maxLength: buffer size.
	^ buffer first: length
]
