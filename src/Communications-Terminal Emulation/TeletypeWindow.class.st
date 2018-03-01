"
I am a kind of SystemWindow intended specifically for hosting a TeletypeMorph.  I provide connection-oriented menus, persistent preferences and menu-based access to my TeletypeMorphs options.


win := TeletypeWindow open.
(ProcessEndpoint command: '/bin/bash' arguments: {'-i'}) asProtocolStack
	push:        XtermEmulator new;
	push:        win tty;
	install;
	run
"
Class {
	#name : #TeletypeWindow,
	#superclass : #SystemWindow,
	#instVars : [
		'tty',
		'windowTitle',
		'iconTitle'
	],
	#classVars : [
		'AutoClose',
		'SaveTelnetOptions',
		'SaveTerminalMainOptions',
		'SaveTerminalSize',
		'SaveTerminalVTOptions',
		'Shortcuts',
		'TerminalType'
	],
	#category : #'Communications-Terminal Emulation'
}

{ #category : #'class initialization' }
TeletypeWindow class >> initialize [
	"TeletypeWindow initialize"

	AutoClose := false.
	SaveTelnetOptions := false.
	SaveTerminalMainOptions := true.
	SaveTerminalSize := false.
	SaveTerminalVTOptions := true.
	TerminalType := XtermEmulator.
	Shortcuts := Dictionary new.
	
]

{ #category : #'instance creation' }
TeletypeWindow class >> new [

	^super new initialize
]

{ #category : #'instance creation' }
TeletypeWindow class >> open [

	^self new openOn: TeletypeMorph new
]

{ #category : #'instance creation' }
TeletypeWindow class >> telnet: hostName [
	"TeletypeWindow telnet: 'localhost'"

	^self telnet: hostName port: 23
]

{ #category : #'instance creation' }
TeletypeWindow class >> telnet: hostName port: portNumber [
	"TeletypeWindow telnet: 'localhost' port: 23"

	| ep tty |
	ep := NetworkEndpoint newConnection: hostName port: portNumber.
	ep isNil ifTrue: [^self error: 'Could not connect'].
	self new openOn: (tty := TeletypeMorph new).
	ep asProtocolStack
		push:	TelnetProtocol new;
		push:	TerminalType new;
		push:	tty;
		install;
		run
]

{ #category : #'menus-window' }
TeletypeWindow >> addConnectMenuTo: aMenu [

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

{ #category : #'menus-config' }
TeletypeWindow >> buildConfigMenu [

	| m |
	m := MenuMorph new defaultTarget: self.

	m
		add: 'terminal type (', TerminalType terminalTypeName, ') '
		subMenu: ((MenuMorph new defaultTarget: self)
			add: 'vt102' selector: #menuBlock: argument: [TerminalType := VT102Emulator];
			balloonTextForLastItem: 'Emulate a VT102 terminal.';
			add: 'xterm' selector: #menuBlock: argument: [TerminalType := XtermEmulator];
			balloonTextForLastItem: 'Emulate an xterm terminal.');
		balloonTextForLastItem: 'Select the kind of terminal emulation to use.'.
	"m
		add: 'font (', SimpleTextMorph defaultFont, ')' subMenu: self buildFontMenu;
		balloonTextForLastItem: 'Set the default font for terminal windows.
(Changes take effect in NEW windows, not this one.)'."

	self menu: m add: 'enable auto-close' var: AutoClose eval: [AutoClose := AutoClose not]
			help: 'Automatically close the window when the session terminates.'.
	m addLine.

	self menu: m add: 'save screen size' var: SaveTerminalSize
			eval: [SaveTerminalSize := SaveTerminalSize not]
			help: 'Save terminal screen size in shortcuts and restore it in new sessions.'.
	self menu: m add: 'save main options' var: SaveTerminalMainOptions
			eval: [SaveTerminalMainOptions := SaveTerminalMainOptions not]
			help: 'Save terminal main options in shortcuts and restore them in new sessions.'.
	self menu: m add: 'save vt options' var: SaveTerminalVTOptions
			eval: [SaveTerminalVTOptions := SaveTerminalVTOptions not]
			help: 'Save terminal VT options in shortcuts and restore them in new sessions.'.
	self menu: m add: 'save telnet options' var: SaveTelnetOptions
			eval: [SaveTelnetOptions := SaveTelnetOptions not]
			help: 'Save telnet protocol options in shortcuts and restore them in new sessions.'.

	m addLine; add: 'restore defaults' selector: #menuBlock: argument: [self menuRestoreDefaults];
		balloonTextForLastItem: 'Reset ALL preferences and option values to their factory settings.'.

	^m
]

{ #category : #'menus-config' }
TeletypeWindow >> buildFontMenu [
	| m |
	m := MenuMorph new defaultTarget: SimpleTextMorph.
	StrikeFont monospacedFamilyNames do: [ :family |
		m add: family
		selector: #defaultFont:
		argument: family;
		 balloonTextForLastItem: 'Set the default font to ', family, '.
(Changes take effect in NEW windows, not this one.)'
	].
	^ m
]

{ #category : #'menus-window' }
TeletypeWindow >> buildWindowMenu [

	| aMenu |
	aMenu := MenuMorph new defaultTarget: self.
	tty isConnected
		ifTrue:
			[aMenu add: 'disconnect' action: #closeConnection.
			 aMenu balloonTextForLastItem: 'Shut down the current session.'.
			 aMenu add: 'save shortcut ...' action: #menuSaveShortcut.
			 aMenu balloonTextForLastItem: 'Save (or modify) a shortcut for the current session.']
		ifFalse:
			[self addConnectMenuTo: aMenu].

	aMenu addLine
		add: 'new window' selector: #menuBlock: argument: [TeletypeWindow open];
		balloonTextForLastItem: 'Open a new, independent teletype window.'.

	tty isConnected
		ifTrue: [aMenu add: 'disconnect and close' action: #delete;
			 		balloonTextForLastItem: 'Shut down the current session and close the window.'.]
		ifFalse: [aMenu add: 'close window' selector: #delete;
			 		balloonTextForLastItem: 'Close the window.'.].

	aMenu addLine;
		add: 'main options' subMenu: tty buildMainMenu;
		balloonTextForLastItem: 'Modify generalt terminal options.';
		add: 'vt options ' subMenu: tty buildVTMenu;
		balloonTextForLastItem: 'Modify VT100 emulation options.';
		add: 'telnet options ' subMenu: TelnetProtocol buildOptionsMenu;
		balloonTextForLastItem: 'Modify telnet protocol options.'.
	aMenu addLine;
		add: 'preferences ' subMenu: self buildConfigMenu;
		balloonTextForLastItem: 'Set preferences for shell and telnet sessions.'.
	aMenu addLine;
		add: 'window ' subMenu: super buildWindowMenu;
		balloonTextForLastItem: 'Modify the characteristics of this window.'.


	^aMenu
]

{ #category : #connections }
TeletypeWindow >> closeConnection [

	(self confirm: 'Really disconnect?') ifTrue: [tty session endpoint close]
]

{ #category : #events }
TeletypeWindow >> collapseOrExpand [

	super collapseOrExpand.
	self setLabel: (self isCollapsed ifTrue: [iconTitle] ifFalse: [windowTitle])
]

{ #category : #events }
TeletypeWindow >> delete [

	(tty isConnected not or: [self confirm: 'There is a session in progress.
Would you like to disconnect and close?
(Answering no will abandon the close request.)'])
		ifFalse: [^self].
	tty delete.
	^super delete

]

{ #category : #events }
TeletypeWindow >> doFastWindowReframe: ptName [
	"Override to provide geometry feedback at display top left and to ensure sane gridding of final bounds."

	| newBounds delta flak w pitch skip grid h |
	"For fast display, only higlight the rectangle during loop"
	flak := self bounds extent - tty textBounds extent.
	pitch := tty pitch.
	skip := tty skip.
	grid := pitch@skip.
	newBounds := self bounds newRectButtonPressedDo: [:f | 
		delta := f extent - flak grid: grid.
		w := delta x // pitch.
		h := delta y // skip.
		delta := delta + flak.
		((' ', w printString, 'x', h printString, ' ') forceTo: 10 paddingWith: $ ) displayAt: 5@5.
		f 
			withSideOrCorner: ptName
			setToPoint: (self pointFromWorld: Sensor cursorPoint)
			minExtent: self minimumExtent].
	delta := (newBounds extent - flak grid: grid) + flak.
	self bounds: (newBounds origin extent: delta).
	self world invalidRect: (5@5 extent: (TextMorph new contents: '999x999') extent)
]

{ #category : #connections }
TeletypeWindow >> endpointClosed [

	AutoClose ifTrue: [^self delete].
	self setLabel: (windowTitle := iconTitle := 'disconnected').
	(ProtocolAdaptor new localEcho) asProtocolStack push: tty; install; run
]

{ #category : #events }
TeletypeWindow >> extent: aPoint [

	super extent: aPoint.
	self isCollapsed ifTrue: [^self].
	tty notNil ifTrue: [tty extent: self ttyLayoutBounds extent].
]

{ #category : #'initialize-release' }
TeletypeWindow >> initialize [

	super initialize.
	self setLabel: (windowTitle := iconTitle := 'Teletype').
	self extent: 10@10.
]

{ #category : #private }
TeletypeWindow >> menu: aMenu add: aString var: aBoolean eval: aBlock help: helpString [

	aMenu
		add: (aBoolean ifTrue: ['<yes>'] ifFalse: ['<no>']), aString
		selector: #menuBlock:
		argument: aBlock;
		balloonTextForLastItem: helpString
]

{ #category : #private }
TeletypeWindow >> menuBlock: aBlock [

	aBlock value
]

{ #category : #'menus-config' }
TeletypeWindow >> menuRestoreDefaults [

	(self confirm: 'Really restore all defaults?
 Note: this will also clear all of your shortcuts! ') ifFalse: [^self].
	TeletypeWindow initialize.
	TeletypeMorph initialize.
	VT102Emulator initialize.
	XtermEmulator initialize.
	TelnetProtocol initialize.
	tty sessionNote: #restoreDefaults
	
]

{ #category : #'menus-window' }
TeletypeWindow >> menuSaveShortcut [

	| shortcut name | 
	shortcut := IdentityDictionary new.
	shortcut at: #sessionType put: #unknown.
	tty sessionNote: #savePreferences with: shortcut.
	name := UIManager default request: 'Shortcut name?' initialAnswer: 'Untitled'.
	(name isNil or: [name isEmpty]) ifTrue: [^self].
	((Shortcuts includesKey: name) and: [(self confirm: 'Replace existing shortcut called `', name, '''?') not])
		ifTrue: [^self].
	Shortcuts at: name put: shortcut.
]

{ #category : #connections }
TeletypeWindow >> newConnection [

	| remote host port |
	remote := UIManager default
		request: 'Remote host name and port?'
		initialAnswer: 'localhost 23'.
	(remote isNil or: [remote size == 0]) ifTrue: [^nil].
	remote := remote substrings.
	remote size < 1 ifTrue: [^nil].
	host := remote first.
	port := remote size > 1 ifTrue: [remote last asInteger].
	port isNil ifTrue: [port := 23].
	self newConnection: host port: port
]

{ #category : #connections }
TeletypeWindow >> newConnection: args [

	^self newConnection: args preferences: nil
]

{ #category : #connections }
TeletypeWindow >> newConnection: hostName port: portNumber [

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

{ #category : #connections }
TeletypeWindow >> newConnection: args preferences: prefs [

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

{ #category : #connections }
TeletypeWindow >> newShell [

	| shell argv prog |
	shell := UIManager default
		request: 'Shell command?'
		initialAnswer: '/bin/bash -i'.
	argv := shell substrings.
	argv isEmpty ifTrue: [^self].
	prog := argv first.
	argv := argv copyFrom: 2 to: argv size.
	self setIconTitle: prog; setWindowTitle: prog.
	(ProcessEndpoint command: prog arguments: argv) asProtocolStack
		push:		TerminalType new;
		push:		tty;
		install;
		run

]

{ #category : #connections }
TeletypeWindow >> newShell: args [

	^self newShell: args preferences: nil
]

{ #category : #connections }
TeletypeWindow >> newShell: args preferences: prefs [

	| argv prog params |
	prog := args first.
	argv := args last.
	params := prefs isNil ifTrue: [IdentityDictionary new] ifFalse: [prefs].
	self setIconTitle: prog; setWindowTitle: prog.
	(ProcessEndpoint command: prog arguments: argv) asProtocolStack
		push: TerminalType new;
		push: tty;
		note: #loadPreferences with: params;
		install;
		run

]

{ #category : #connections }
TeletypeWindow >> newShortcut: shortcut [

	| epClass epArgs |
	self savePreferences: shortcut.
	epClass := shortcut at: #endpointClass.
	epArgs := shortcut at: #endpointArguments.
	epClass == #ProcessEndpoint ifTrue: [^self newShell: epArgs preferences: shortcut].
	epClass == #NetworkEndpoint ifTrue: [^self newConnection: epArgs preferences: shortcut].
	self error: 'I don''t know how to create an endpoint of type ', epClass
]

{ #category : #'menus-window' }
TeletypeWindow >> offerWindowMenu [

	| aMenu |
	aMenu := self buildWindowMenu.
	aMenu popUpEvent: self currentEvent in: self world
]

{ #category : #'initialize-release' }
TeletypeWindow >> openOn: ttyMorph [
	"Open a new SystemWindow containing just a ttyMorph."

	| ext |
	self setLabel: windowTitle.
	tty := ttyMorph setWindow: self.
	self
		addMorph: tty frame: (0 @ 0 corner: 1 @ 1);
		model: tty.
	"Figure out what our extent should be based on how much extra space we use for decoration."
	ext := tty preferredExtent						"the extent that the tty would like to receive"
		+ self extent - self ttyLayoutBounds extent.	"window decoration"
	self activeHand keyboardFocus: nil.			"make sure we get focus when we're opened"
	self extent: ext; openInWorldExtent: ext.
	tty install; run
]

{ #category : #'initialize-release' }
TeletypeWindow >> openOn: ttyMorph labeled: aString [
	"Open a new SystemWindow containing just a ttyMorph."

	windowTitle := iconTitle := aString.
	^self openOn: ttyMorph
]

{ #category : #events }
TeletypeWindow >> qdoFastWindowReframe: ptName [
	"Override to provide geometry feedback at display top left and to ensure sane gridding of final bounds."

	| newBounds delta flak w pitch skip grid h |
	"For fast display, only higlight the rectangle during loop"
	flak := self bounds extent - tty textBounds extent.
	pitch := tty pitch.
	skip := tty skip.
	grid := pitch@skip.
	newBounds := self bounds newRectButtonPressedDo: [:f | 
		delta := f extent - flak grid: grid.
		w := delta x // pitch.
		h := delta y // skip.
		delta := delta + flak.
		((' ', w printString, 'x', h printString, ' ') forceTo: 10 paddingWith: $ ) displayAt: 5@5.
		f 
			withSideOrCorner: ptName
			setToPoint: (self pointFromWorld: Sensor cursorPoint)
			minExtent: self minimumExtent].
	delta := (newBounds extent - flak grid: grid) + flak.
	self bounds: (newBounds origin extent: delta).
	self world invalidRect: (5@5 extent: (TextMorph new contents: '999x999') extent).
	self activeHand newKeyboardFocus: self
]

{ #category : #'menus-window' }
TeletypeWindow >> removeShortcut: name [

	Shortcuts removeKey: name ifAbsent: []
]

{ #category : #private }
TeletypeWindow >> savePreferences: dict [

	dict
		at: #saveTerminalSize put: SaveTerminalSize;
		at: #saveTerminalMainOptions put: SaveTerminalMainOptions;
		at: #saveTerminalVTOptions put: SaveTerminalVTOptions;
		at: #saveTelnetOptions put: SaveTelnetOptions
]

{ #category : #accessing }
TeletypeWindow >> setIconTitle: aString [

	iconTitle := aString.
	self isCollapsed ifTrue: [self setLabel: aString].
]

{ #category : #private }
TeletypeWindow >> setLabel: aString [

	labelString = aString ifFalse: [super setLabel: aString]
]

{ #category : #accessing }
TeletypeWindow >> setWindowTitle: aString [

	windowTitle := aString.
	self isCollapsed ifFalse: [self setLabel: aString].
]

{ #category : #accessing }
TeletypeWindow >> tty [

	^ tty
]

{ #category : #private }
TeletypeWindow >> ttyLayoutBounds [

	^self layoutBounds
]
