Class {
	#name : #BaselineOfTerminalEmulator,
	#superclass : #BaselineOf,
	#category : #BaselineOfTerminalEmulator
}

{ #category : #baselines }
BaselineOfTerminalEmulator >> baseline: spec [
	<baseline>

	spec for: #common do: [
		spec 
			package: 'TerminalEmulator-Core';
			package: 'TerminalEmulator-PseudoTTY';
			"package: 'TerminalEmulator-Network';"
			package: 'TerminalEmulator-Tests';
			package: 'TerminalEmulator-UI'
	].		
]
