"
I am a simple (but complete) state machine.  I recognise sequences of characters (with embedded numeric arguments for certain sequences) in strings.  I also print out what I'm doing on the Transcript so that you can see precisely how I work.

	StatefulProtocolTester test

Structure:
 prefix		SmallInteger	-- the numeric argument currently under contruction
"
Class {
	#name : #StatefulProtocolTester,
	#superclass : #StatefulProtocol,
	#instVars : [
		'prefix'
	],
	#classVars : [
		'States'
	],
	#category : #'TerminalEmulator-Tests'
}

{ #category : #examples }
StatefulProtocolTester class >> test [
	"StatefulProtocolTester test"

	| sm input |
	sm := self initialState: (StatefulProtocolDescription example compile).
	sm client: sm.
	input := '1x2xx3xxx4y5xy6yy7xyx8xyy9xyz10zyx'.
	Transcript cr; show: 'input is ' , input printString ; cr.
	'1x2xx3xxx4y5xy6yy7xyx8xyy9xyz10xy42zzyx' do: [: c | sm step: c].
	Transcript cr; show: ' final state is ' , sm state name printString; cr.
]

{ #category : #actions }
StatefulProtocolTester >> addPrefix: anObject [

	prefix := prefix * 10 + anObject asInteger - 48
]

{ #category : #actions }
StatefulProtocolTester >> echo: anObject [

	Transcript show: anObject printString
]

{ #category : #actions }
StatefulProtocolTester >> echox: anObject [

	Transcript show: ' <saw X> ' , anObject printString
]

{ #category : #actions }
StatefulProtocolTester >> echoxy: anObject [

	Transcript show: ' <saw XY> ' , anObject printString
]

{ #category : #actions }
StatefulProtocolTester >> echoxyz: anObject [

	Transcript show: ' <saw XYZ prefix ' , prefix printString , ' > ' , anObject printString
]

{ #category : #actions }
StatefulProtocolTester >> initPrefix: anObject [

	prefix := 0
]

{ #category : #'state transitions' }
StatefulProtocolTester >> step: anObject [
	Transcript cr;
		print: currentState name;
		nextPutAll: ' step: ';
		print: anObject;
		nextPutAll: ' -> ';
		endEntry.
	self upcall: anObject.
]
