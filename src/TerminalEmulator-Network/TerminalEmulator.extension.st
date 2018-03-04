Extension { #name : #TerminalEmulator }

{ #category : #'*TerminalEmulator-Network' }
TerminalEmulator >> addConnectMenuTo: aMenu [

	| connectMenu removeMenu value |

	Shortcuts isEmpty
		ifFalse:
			[connectMenu := MenuMorph new defaultTarget: self.
			 removeMenu := MenuMorph new defaultTarget: self.
			 Shortcuts keys asSortedCollection do: [ :key |
				value := Shortcuts at: key.
				connectMenu add: key selector: #newShortcut: argument: value.
				connectMenu balloonTextForLastItem: 'Open a session for ', (value at: #endpointArguments) first printString, '.'.
				removeMenu add: key selector: #removeShortcut: argument: key.
				removeMenu balloonTextForLastItem: 'Delete the shorcut for ', (value at: #endpointArguments) first printString, '.'].
			 connectMenu addLine.
			 connectMenu add: 'remove shortcut ' subMenu: removeMenu.
			 connectMenu balloonTextForLastItem: 'Delete a shortcut.'.
			 connectMenu add: 'clear shortcuts' selector: #menuBlock: argument: [Shortcuts := Dictionary new].
			 connectMenu balloonTextForLastItem: 'Delete all shortcuts.'.
			 aMenu add: 'shortcuts ' subMenu: connectMenu.
			 aMenu balloonTextForLastItem: 'Open a session from a previously saved shortcut.'].

	aMenu add: 'new shell session ...' selector: #newShell;
		balloonTextForLastItem: 'Run a new local program in this window.'.
	aMenu add: 'new telnet session ...' selector: #newConnection;
		balloonTextForLastItem: 'Open a new telnet connection in this window.'.
]

{ #category : #'*TerminalEmulator-Network' }
TerminalEmulator >> newConnection: hostName port: portNumber [

	| ep |
	tty upcallAll: ('Trying ', hostName, '...') asByteArray; newline; flush.
	ep := NetworkEndpoint newConnection: hostName port: portNumber.
	ep isNil ifTrue: [^self error: 'Could not connect'].
	self setIconTitle: hostName; setWindowTitle: hostName.
	^ep asProtocolStack
		push:		TelnetProtocol new;
		push:		TerminalType new;
		push:		tty;
		install;
		run
]

{ #category : #'*TerminalEmulator-Network' }
TerminalEmulator >> newConnection: args preferences: prefs [

	| hostName portNumber ep params |
	hostName := args first.
	portNumber := args last.
	params := prefs isNil ifTrue: [IdentityDictionary new] ifFalse: [prefs].
	tty upcallAll: ('Trying ', hostName, '...') asByteArray; newline; flush.
	ep := NetworkEndpoint newConnection: hostName port: portNumber.
	ep isNil ifTrue: [^self error: 'Could not connect'].
	self setIconTitle: hostName; setWindowTitle: hostName.
	^ep asProtocolStack
		push: TelnetProtocol new;
		push: TerminalType new;
		push: tty;
		note: #loadPreferences with: params;
		install;
		run
]

{ #category : #'*TerminalEmulator-Network' }
TerminalEmulator class >> telnet: hostName port: portNumber [
	"TeletypeWindow telnet: 'localhost' port: 23"

	| ep tty |
	ep := NetworkEndpoint newConnection: hostName port: portNumber.
	ep isNil ifTrue: [^self error: 'Could not connect'].
	self new openOn: (tty := TerminalEmulatorMorph new).
	ep asProtocolStack
		push:	TelnetProtocol new;
		push:	TerminalType new;
		push:	tty;
		install;
		run
]
