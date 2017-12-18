"
I am just like StatefulProtocolTester except that I measure the throughput of the protocol as number of state transitions per second.

	StatefulProtocolTester2 test
"
Class {
	#name : #StatefulProtocolTester2,
	#superclass : #StatefulProtocolTester,
	#instVars : [
		'e',
		'x',
		'xy',
		'xyz'
	],
	#category : #'Communications-Abstract'
}

{ #category : #examples }
StatefulProtocolTester2 class >> test [
	"A version of StatefulProtocolTester that measures throughput (in transitions per second)."

	"StatefulProtocolTester2 test"

	| sm input stream size time |
	sm := self initialState: (StatefulProtocolDescription example compile).
	sm client: sm.
	input := '1x2xx3xxx4y5xy6yy7xyx8xyy9xyz10zyx'.
	Transcript cr; show: 'input is ' , input printString ; cr.
	stream := WriteStream on: input.
	[stream contents size < 100000] whileTrue: [stream nextPutAll: input].
	Transcript show: 'size is ' , (size := stream contents size) printString; cr.
	input := ReadStream on: stream contents.
	time := Time millisecondsToRun: [sm reset; upcallAll: input].
	Transcript show: sm printString , ' in ' , time printString , 'ms'; cr.
	Transcript show: (size / time * 1000) asInteger printString,
		' state transitions per second'
]

{ #category : #actions }
StatefulProtocolTester2 >> echo: anObject [

	e := e + 1
]

{ #category : #actions }
StatefulProtocolTester2 >> echox: anObject [

	x := x + 1
]

{ #category : #actions }
StatefulProtocolTester2 >> echoxy: anObject [

	xy := xy + 1
]

{ #category : #actions }
StatefulProtocolTester2 >> echoxyz: anObject [

	xyz := xyz + 1
]

{ #category : #printing }
StatefulProtocolTester2 >> printOn: aStream [

	aStream cr; nextPutAll: 'saw ',
		e printString, ' unmatched characters, ',
		x printString, ' x, ',
		xy printString, ' xy, ',
		xyz printString, ' xyz'.
]

{ #category : #'initialize-release' }
StatefulProtocolTester2 >> reset [

	e := x := xy := xyz := 0
]
