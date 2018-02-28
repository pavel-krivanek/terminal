Extension { #name : #LibC }

{ #category : #'*PseudoTTYLib' }
LibC >> duplicateFileDescriptor: aFileDescriptor [
 
	 ^self ffiCall: #(int dup(int aFileDescriptor)) 
]

{ #category : #'*PseudoTTYLib' }
LibC >> duplicateFileDescriptor: aFileDescriptor to: anotherFileDescriptor [
 
	 ^self ffiCall: #(int dup2(int aFileDescriptor, int anotherFileDescriptor)) 
]

{ #category : #'*PseudoTTYLib' }
LibC >> execl: aCommand [

	 ^self ffiCall: #(int execl(char* aCommand, char* aCommand, 0)) 
]

{ #category : #'*PseudoTTYLib' }
LibC >> execl: aCommand with: anArgument [

	 ^self ffiCall: #(int execl(String aCommand, String aCommand, String anArgument, 0))
]

{ #category : #'*PseudoTTYLib' }
LibC >> execvp: anArray [

	"Put a 0 at the end of the array"
	^ self execvp: anArray first withArguments: (anArray copyWith: 0)
]

{ #category : #'*PseudoTTYLib' }
LibC >> execvp: aCommand withArguments: arguments [

	 ^self ffiCall: #(int execv(char* aCommand, char** arguments)) 
]

{ #category : #'*PseudoTTYLib' }
LibC >> fork [

	 ^self ffiCall: #(int fork(void)) 
]

{ #category : #'*PseudoTTYLib' }
LibC >> fsync: aFileDescriptor [
 
	 ^self ffiCall: #(int fsync(int aFileDescriptor)) 
]

{ #category : #'*PseudoTTYLib' }
LibC >> privErrno [
	
	^ (ExternalAddress loadSymbol: #errno from: LibC) signedLongAt: 1
]

{ #category : #'*PseudoTTYLib' }
LibC >> privStrerror: errnum [

	^ self ffiCall: #(char * strerror(int errnum))
]
