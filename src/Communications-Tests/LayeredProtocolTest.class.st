"
I'm testing the class LayeredProtocol
"
Class {
	#name : #LayeredProtocolTest,
	#superclass : #ClassTestCase,
	#instVars : [
		'log',
		'reflector',
		'simpleTracer1',
		'simpleTracer2',
		'tracer',
		'session'
	],
	#category : #'Communications-Tests'
}

{ #category : #coverage }
LayeredProtocolTest >> classToBeTested [
	
	^ LayeredProtocol
]

{ #category : #tests }
LayeredProtocolTest >> setUp [

	log := OrderedCollection new.
	
	reflector := ProtocolAdaptor new reflect.
	simpleTracer1 := ProtocolAdaptor new traceTo: log.
	simpleTracer2 := ProtocolAdaptor new traceTo: log.
	tracer := (ProtocolAdaptor new traceTo: log)
		upBlock: [:arg | log add: {#ping. arg}].
	
	session := (LayeredProtocol on: reflector)
		push: simpleTracer1;
		push: simpleTracer2;
		push: tracer;
		install;
		run.
		
	
]

{ #category : #tests }
LayeredProtocolTest >> testAddDown [

	| newProtocol |
	
	newProtocol := ProtocolAdaptor new.
	
	session addDown: newProtocol.
	self assert: session endpoint identicalTo: newProtocol.
	self assert: session size equals: 5.
]

{ #category : #tests }
LayeredProtocolTest >> testIsConnnected [

	"the testing session is not connected for real"
	self deny: session isConnected 
]

{ #category : #tests }
LayeredProtocolTest >> testOrder [

	self assert: session head identicalTo: tracer.	
	self assert: session endpoint identicalTo: reflector.
	self assert: session tail identicalTo: session endpoint.
]

{ #category : #tests }
LayeredProtocolTest >> testPop [

	session pop.
	self assert: session head identicalTo: simpleTracer2.
	session pop.
	self assert: session head identicalTo: simpleTracer1
]

{ #category : #tests }
LayeredProtocolTest >> testProperties [

	self assert: (session propertyAt: #someProperty) isNil.	
	self assert: (session propertyAt: #someProperty ifAbsent: [ #missing ]) equals: #missing.	
	"ensure the property was not set for real"
	self assert: (session propertyAt: #someProperty) isNil. 

	session propertyAt: #someProperty put: #newValue.
	self assert: (session propertyAt: #someProperty) equals: #newValue.. 
	

]

{ #category : #tests }
LayeredProtocolTest >> testReflection [ 

	| anObject |
	
	anObject := 42.
	session first downcall: anObject.
		
	self assertCollection: log asArray equals: { 
		{ #down. anObject }. 
		{ #down. anObject }. 
		{ #down. anObject }. 
		{ #up. anObject }. 
		{ #up. anObject }. 
		{ #ping. anObject }}.
		
	
]

{ #category : #tests }
LayeredProtocolTest >> testSize [

	self assert: session size equals: 4 
]
