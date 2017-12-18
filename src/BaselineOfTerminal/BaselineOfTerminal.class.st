Class {
	#name : #BaselineOfTerminal,
	#superclass : #BaselineOf,
	#category : #BaselineOfTerminal
}

{ #category : #baselines }
BaselineOfTerminal >> baseline: spec [
	<baseline>

	spec for: #common do: [
		spec 
			package: 'Communications-Abstract';
			package: 'Communications-Endpoints';
			package: 'Communications-Protocols';
			package: 'Communications-Terminal Emulation';
			package: 'PseudoTTYLib'.
	].		
]
