"
AioPlugin driven file read/write operations
"
Class {
	#name : #PseudoTTYResourceChecker,
	#superclass : #Object,
	#instVars : [
		'fileDescriptors',
		'semaphore',
		'semaphoreIndex',
		'read',
		'write',
		'exceptions'
	],
	#category : #'TerminalEmulator-PseudoTTY'
}

{ #category : #'waiting-specific' }
PseudoTTYResourceChecker class >> waitFor: aFileDescriptor [
	^ self waitForAll: {aFileDescriptor}
]

{ #category : #'waiting-specific' }
PseudoTTYResourceChecker class >> waitForAll: someFileDescriptors [
	^ self waitForAll: someFileDescriptors forRead: true write: false orException: true.
]

{ #category : #'waiting-specific' }
PseudoTTYResourceChecker class >> waitForAll: someFileDescriptors forRead: read write: write orException: exceptions. [
	^ self new
		fileDescriptors: someFileDescriptors;
		read: read;
		write: write;
		exceptions: exceptions;
		wait
]

{ #category : #accessing }
PseudoTTYResourceChecker >> cleanUp [
	fileDescriptors do: [ :fd | self primitiveAioDisable: fd ].
	Smalltalk unregisterExternalObject: semaphore.
	semaphore := nil
]

{ #category : #accessing }
PseudoTTYResourceChecker >> enable [
	fileDescriptors
		do: [ :fd | self primitiveAioEnable: fd semaphoreIndex: semaphoreIndex isExternal: true ]
]

{ #category : #accessing }
PseudoTTYResourceChecker >> exceptions [
	^ exceptions
]

{ #category : #accessing }
PseudoTTYResourceChecker >> exceptions: anObject [
	exceptions := anObject
]

{ #category : #accessing }
PseudoTTYResourceChecker >> fileDescriptors [
	^ fileDescriptors
]

{ #category : #accessing }
PseudoTTYResourceChecker >> fileDescriptors: anObject [
	fileDescriptors := anObject
]

{ #category : #accessing }
PseudoTTYResourceChecker >> handle [
	fileDescriptors
		do: [ :fd | 
			self
				primitiveAioHandle: fd
				exception: exceptions
				read: read
				write: write]
]

{ #category : #accessing }
PseudoTTYResourceChecker >> initialize [
	read := true.
	write := false.
	exceptions := true.
]

{ #category : #accessing }
PseudoTTYResourceChecker >> primitiveAioDisable: fd [
	<primitive: primitiveAioDisable  module: 'AioPlugin'>
	^ self primitiveFail.
]

{ #category : #accessing }
PseudoTTYResourceChecker >> primitiveAioEnable: fd semaphoreIndex: index isExternal: external [
	<primitive: primitiveAioEnable  module: 'AioPlugin'>
	^ self primitiveFail.
]

{ #category : #accessing }
PseudoTTYResourceChecker >> primitiveAioHandle: fd exception: exception read: read write: write [
	<primitive: primitiveAioHandle  module: 'AioPlugin'>
	^ self primitiveFail.
]

{ #category : #accessing }
PseudoTTYResourceChecker >> read [
	^ read
]

{ #category : #accessing }
PseudoTTYResourceChecker >> read: anObject [
	read := anObject
]

{ #category : #accessing }
PseudoTTYResourceChecker >> wait [
	[
		semaphore := Semaphore new.
		semaphoreIndex := Smalltalk registerExternalObject: semaphore.
		
		self enable.
		self handle.
		
		semaphore wait.
	]ensure: [ 
		self cleanUp.
	]
]

{ #category : #accessing }
PseudoTTYResourceChecker >> write [
	^ write
]

{ #category : #accessing }
PseudoTTYResourceChecker >> write: anObject [
	write := anObject
]
