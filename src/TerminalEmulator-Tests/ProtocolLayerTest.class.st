"
I'm testing the class ProtocolLayer
"
Class {
	#name : #ProtocolLayerTest,
	#superclass : #ClassTestCase,
	#instVars : [
		'layer'
	],
	#category : #'TerminalEmulator-Tests'
}

{ #category : #running }
ProtocolLayerTest >> setUp [
	
	layer := ProtocolLayer new.
]

{ #category : #coverage }
ProtocolLayerTest >> testAsProtocolStack [
	
	| session |

	session := layer asProtocolStack.
	self assert: session size equals: 1.
	self assert: session head equals: session endpoint.
	self assert: session head equals: layer.

]

{ #category : #coverage }
ProtocolLayerTest >> testInstalled [
	
	| session |

	session := layer asProtocolStack.
	self assert: layer session isNil.
	session install.
	self assert: layer session equals: session.
]

{ #category : #tests }
ProtocolLayerTest >> testUpcall [

	layer upcall: 42
]
