Extension { #name : #LibC }

{ #category : #'*TerminalEmulator-PseudoTTY' }
LibC >> duplicateFileDescriptor: aFileDescriptor [
 
	 ^self ffiCall: #(int dup(int aFileDescriptor)) 
]

{ #category : #'*TerminalEmulator-PseudoTTY' }
LibC >> duplicateFileDescriptor: aFileDescriptor to: anotherFileDescriptor [
 
	 ^self ffiCall: #(int dup2(int aFileDescriptor, int anotherFileDescriptor)) 
]

{ #category : #'*TerminalEmulator-PseudoTTY' }
LibC >> execl: aCommand [

	 ^self ffiCall: #(int execl(char* aCommand, char* aCommand, 0)) 
]

{ #category : #'*TerminalEmulator-PseudoTTY' }
LibC >> execl: aCommand with: anArgument [

	 ^self ffiCall: #(int execl(char* aCommand, char* aCommand, char* anArgument, 0)) 
]

{ #category : #'*TerminalEmulator-PseudoTTY' }
LibC >> execvp: anArray [

	"Put a 0 at the end of the array"
	^ self execvp: anArray first withArguments: (anArray copyWith: 0)
]

{ #category : #'*TerminalEmulator-PseudoTTY' }
LibC >> execvp: aCommand withArguments: arguments [

	 ^self ffiCall: #(int execv(char* aCommand, char** arguments)) 
]

{ #category : #'*TerminalEmulator-PseudoTTY' }
LibC >> fork [

	 ^self ffiCall: #(int fork(void)) 
]

{ #category : #'*TerminalEmulator-PseudoTTY' }
LibC >> fsync: aFileDescriptor [
 
	 ^self ffiCall: #(int fsync(int aFileDescriptor)) 
]

{ #category : #'*TerminalEmulator-PseudoTTY' }
LibC >> privErrno [
	
	^ (ExternalAddress loadSymbol: #errno from: LibC) signedLongAt: 1
]

{ #category : #'*TerminalEmulator-PseudoTTY' }
LibC >> privStrerror: errnum [

	^ self ffiCall: #(char * strerror(int errnum))
]
