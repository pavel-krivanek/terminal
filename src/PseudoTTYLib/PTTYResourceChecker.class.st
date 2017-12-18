Class {
	#name : #PTTYResourceChecker,
	#superclass : #Object,
	#instVars : [
		'fileDescriptors',
		'semaphore',
		'semaphoreIndex',
		'read',
		'write',
		'exceptions'
	],
	#category : #PseudoTTYLib
}

{ #category : #'waiting-specific' }
PTTYResourceChecker class >> waitFor: aFileDescriptor [
	^ self waitForAll: {aFileDescriptor}
]

{ #category : #'waiting-specific' }
PTTYResourceChecker class >> waitForAll: someFileDescriptors [
	^ self waitForAll: someFileDescriptors forRead: true write: false orException: true.
]

{ #category : #'waiting-specific' }
PTTYResourceChecker class >> waitForAll: someFileDescriptors forRead: read write: write orException: exceptions. [
	^ self new
		fileDescriptors: someFileDescriptors;
		read: read;
		write: write;
		exceptions: exceptions;
		wait
]

{ #category : #accessing }
PTTYResourceChecker >> cleanUp [
	fileDescriptors do: [ :fd | self primitiveAioDisable: fd ].
	Smalltalk unregisterExternalObject: semaphore.
	semaphore := nil
]

{ #category : #accessing }
PTTYResourceChecker >> enable [
	fileDescriptors
		do: [ :fd | self primitiveAioEnable: fd semaphoreIndex: semaphoreIndex isExternal: true ]
]

{ #category : #accessing }
PTTYResourceChecker >> exceptions [
	^ exceptions
]

{ #category : #accessing }
PTTYResourceChecker >> exceptions: anObject [
	exceptions := anObject
]

{ #category : #accessing }
PTTYResourceChecker >> fileDescriptors [
	^ fileDescriptors
]

{ #category : #accessing }
PTTYResourceChecker >> fileDescriptors: anObject [
	fileDescriptors := anObject
]

{ #category : #accessing }
PTTYResourceChecker >> handle [
	fileDescriptors
		do: [ :fd | 
			self
				primitiveAioHandle: fd
				exception: exceptions
				read: read
				write: write]
]

{ #category : #accessing }
PTTYResourceChecker >> initialize [
	read := true.
	write := false.
	exceptions := true.
]

{ #category : #accessing }
PTTYResourceChecker >> primitiveAioDisable: fd [
	<primitive: primitiveAioDisable  module: 'AioPlugin'>
	^ self primitiveFail.
]

{ #category : #accessing }
PTTYResourceChecker >> primitiveAioEnable: fd semaphoreIndex: index isExternal: external [
	<primitive: primitiveAioEnable  module: 'AioPlugin'>
	^ self primitiveFail.
]

{ #category : #accessing }
PTTYResourceChecker >> primitiveAioHandle: fd exception: exception read: read write: write [
	<primitive: primitiveAioHandle  module: 'AioPlugin'>
	^ self primitiveFail.
]

{ #category : #accessing }
PTTYResourceChecker >> read [
	^ read
]

{ #category : #accessing }
PTTYResourceChecker >> read: anObject [
	read := anObject
]

{ #category : #accessing }
PTTYResourceChecker >> wait [
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
PTTYResourceChecker >> write [
	^ write
]

{ #category : #accessing }
PTTYResourceChecker >> write: anObject [
	write := anObject
]
