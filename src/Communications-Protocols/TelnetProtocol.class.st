"
I am a ProtocolLayer implementing the telnet (RFC 854) protocol.  I expect to be inserted into a LayeredProtocol stack in which the endpoint is connected to a remote telnet server.  When I receive #run from the protocol stack I will begin negotiation with the remove server.  If the negotiation is successful, the protocol above me in the stack (or the client of the entire stack) will see an interactive login session.
"
Class {
	#name : #TelnetProtocol,
	#superclass : #StatefulProtocol,
	#instVars : [
		'debug',
		'dumpNetData',
		'dumpTermData',
		'doNAWS',
		'cols',
		'rows'
	],
	#classVars : [
		'AO',
		'AYT',
		'Break',
		'Commands',
		'DataMark',
		'Debug',
		'Do',
		'Dont',
		'DumpNetData',
		'DumpTermData',
		'EC',
		'EL',
		'Echo',
		'EnvironmentOption',
		'ForwardX',
		'GoAhead',
		'IAC',
		'IP',
		'Is',
		'Linemode',
		'Logout',
		'NAWS',
		'NewEnvironment',
		'Nop',
		'Options',
		'RemoteFlowControl',
		'SB',
		'SE',
		'Send',
		'Status',
		'Subnegotiation',
		'SuppressGoAhead',
		'SuppressLocalEcho',
		'TerminalSpeed',
		'TerminalType',
		'Will',
		'Wont',
		'XDisplayLocation'
	],
	#classInstVars : [
		'States'
	],
	#category : #'Communications-Protocols'
}

{ #category : #menu }
TelnetProtocol class >> buildOptionsMenu [

	| m |
	m := MenuMorph new defaultTarget: self.
	self menu: m add: 'show options processing' var: Debug eval: [Debug := Debug not]
			help: 'Dispay telnet options negotiation.'.
	self menu: m add: 'print network data' var: DumpNetData eval: [DumpNetData := DumpNetData not]
			help: 'Dispay raw network data.'.
	self menu: m add: 'print terminal data' var: DumpTermData eval: [DumpTermData := DumpTermData not]
			help: 'Dispay raw terminal data.'.
	^m
]

{ #category : #accessing }
TelnetProtocol class >> debug [

	^Debug
]

{ #category : #'class initialization' }
TelnetProtocol class >> initialize [
	"TelnetProtocol initialize"

	Debug := false.
	DumpNetData := false.
	DumpTermData := false.
	self initializeConstants.
	self initializeProtocol.
]

{ #category : #'class initialization' }
TelnetProtocol class >> initializeConstants [

	(Commands := IdentityDictionary new)
		"	constant name		  value		 diagnostic name	disobfuscational remarks"
		at: (SE					:= 240)	put: 'SE';				"Subnegotiation End"
		at: (Nop					:= 241)	put: 'NOP';				"No OPeration"
		at: (DataMark			:= 242)	put: 'DATA-MARK';
		at: (Break				:= 243)	put: 'BREAK';
		at: (IP					:= 244)	put: 'IP';				"Interrupt Process"
		at: (AO					:= 245)	put: 'AO';				"Abort Output"
		at: (AYT					:= 246)	put: 'AYT';				"Are You There?"
		at: (EC					:= 247)	put: 'EC';				"Erase Character"
		at: (EL					:= 248)	put: 'EL';				"Erase Line"
		at: (GoAhead			:= 249)	put: 'GO-AHEAD';
		at: (SB					:= 250)	put: 'SB';				"Subnegotiation Begin"
		at: (Will					:= 251)	put: 'WILL';
		at: (Wont				:= 252)	put: 'WONT';
		at: (Do					:= 253)	put: 'DO';
		at: (Dont				:= 254)	put: 'DONT';
		at: (IAC					:= 255)	put: 'IAC'.				"Interpret As Command"
	(Options := IdentityDictionary new)
		at: (Echo				:= 1)		put: 'ECHO';
		at: (SuppressGoAhead	:= 3)		put: 'SUPPRESS-GO-AHEAD';
		at: (Status				:= 5)		put: 'STATUS';
		at: (Logout				:= 18)	put: 'LOGOUT';
		at: (TerminalType		:= 24)	put: 'TERMINAL-TYPE';
		at: (NAWS				:= 31)	put: 'NAWS';
		at: (TerminalSpeed		:= 32)	put: 'TERMINAL-SPEED';
		at: (RemoteFlowControl	:= 33)	put: 'REMOTE-FLOW-CONTROL';
		at: (Linemode			:= 34)	put: 'LINEMODE';
		at: (XDisplayLocation	:= 35)	put: 'X-DISPLAY-LOCATION';
		at: (EnvironmentOption	:= 36)	put: 'ENVIRONMENT-OPTION';
		at: (NewEnvironment	:= 39)	put: 'NEW-ENVIRONMENT';
		at: (SuppressLocalEcho	:= 45)	put: 'SUPPRESS-LOCAL-ECHO';
		at: (ForwardX			:= 49)	put: 'FORWARD-X'.
	(Subnegotiation := IdentityDictionary new)
		at: (Is					:= 0)		put: 'IS';
		at: (Send				:= 1)		put: 'SEND'.
]

{ #category : #'class initialization' }
TelnetProtocol class >> initializeProtocol [
	"TelnetProtocol initialize"

	| desc |
	desc := StatefulProtocolDescription initialState: #relax.

	(desc newState: #relax				-> (#passUp:						-> nil))
		add: IAC							-> (nil							-> #iac).

	(desc newState: #iac					-> (#iacIgnored:					-> #relax))
		add: Do							-> (nil							-> #iacDo);
		add: Dont						-> (nil							-> #iacDont);
		add: Will						-> (nil							-> #iacWill);
		add: SB							-> (nil							-> #iacSB);
		add: DataMark					-> (#iacDataMark:				-> #relax)";
		add: Nop						-> (#iacNop:						-> #relax);
		add: Wont						-> (nil							-> #iacWont);
		add: IAC							-> (#iacIAC:						-> #relax)".

	(desc newState: #iacDo				-> (#iacDo:						-> #relax))
		add: Echo						-> (#iacDoEcho:					-> #relax);
		add: TerminalType				-> (#iacDoTerminalType:			-> #relax);
		add: NAWS						-> (#iacDoNAWS:					-> #relax);
		add: TerminalSpeed				-> (#iacDoTerminalSpeed:			-> #relax);
		add: RemoteFlowControl			-> (#iacDoFlowControl:			-> #relax);
		add: XDisplayLocation			-> (#iacDoXDisplay:				-> #relax);
		add: EnvironmentOption			-> (#iacDoEnvironmentOpt:		-> #relax);
		add: NewEnvironment			-> (#iacDoNewEnvironment:		-> #relax).

	(desc newState: #iacDont				-> (#iacDont:					-> #relax))
		add: NAWS						-> (#iacDontNAWS:				-> #relax).

	(desc newState: #iacWill				-> (#iacWill:						-> #relax))	
		add: Echo						-> (#iacWillEcho:				-> #relax);
		add: SuppressGoAhead			-> (#iacWillSuppressGoAhead:	-> #relax).

	"xxx THE FOLLOWING SHOULD BE GENERIC WITH SB ARG ACCUMULATOR VIZ TERM EMU xxx"

	(desc newState: #iacSB				-> (#iacSB:						-> #relax))
		add: TerminalType				-> (nil							-> #sbTermType).

	(desc newState: #sbTermType		-> (nil							-> #relax))
		add: Send						-> (nil							-> #sbTermTypeSend).

	(desc newState: #sbTermTypeSend	-> (nil							-> #relax))
		add: IAC							-> (nil							-> #sbTermTypeSendIAC).

	(desc newState: #sbTermTypeSendIAC	-> (nil							-> #relax))
		add: SE							-> (#sbTerminalTypeSend:		-> #relax).

	States := desc compile
]

{ #category : #menu }
TelnetProtocol class >> menu: aMenu add: aString var: aBoolean eval: aBlock help: helpString [

	aMenu
		add: (aBoolean ifTrue: ['<yes>'] ifFalse: ['<no>']), aString
		selector: #menuBlock:
		argument: aBlock;
		balloonTextForLastItem: helpString
]

{ #category : #menu }
TelnetProtocol class >> menuBlock: aBlock [

	aBlock value
]

{ #category : #'instance creation' }
TelnetProtocol class >> new [
	"TelnetProtocol new"

	^super new initialState: States
]

{ #category : #accessing }
TelnetProtocol class >> toggleDebugging [

	Debug := Debug not
]

{ #category : #debugging }
TelnetProtocol >> commandName: cmd [

	^Commands at: cmd ifAbsent: [cmd printString]
]

{ #category : #debugging }
TelnetProtocol >> cr [

	self dump: String cr withInternetLineEndings
]

{ #category : #debugging }
TelnetProtocol >> debug: message [

	self dump: message; dump: String crlf
]

{ #category : #protocol }
TelnetProtocol >> downcall: aChar [

	dumpTermData ifTrue: [self dump: '['; dumpHex: aChar; dump: ']'].
	super downcall: aChar
]

{ #category : #debugging }
TelnetProtocol >> dump: message [

	message do: [:c | up upcall: c asInteger].
	up flush
]

{ #category : #debugging }
TelnetProtocol >> dumpHex: char [

	| str |
	str := char printStringBase: 16.
	str := str copyFrom: 4 to: str size.
	self dump: (str padded: #left to: 2 with: $0)
]

{ #category : #'commands-other' }
TelnetProtocol >> iacDataMark: arg [

	debug ifTrue: [self rcvd: DataMark]
]

{ #category : #'commands-do' }
TelnetProtocol >> iacDo: arg [

	debug ifTrue: [self rcvd: Do with: arg].
	"Assume it's a command we don't want to deal with: refuse it."
	self sendIacWont: arg
]

{ #category : #'commands-do' }
TelnetProtocol >> iacDoEcho: arg [

	debug ifTrue: [self rcvd: Do with: Echo].
	self sendIacWont: Echo
]

{ #category : #'commands-do' }
TelnetProtocol >> iacDoEnvironmentOpt: arg [

	debug ifTrue: [self rcvd: Do with: arg].
	self sendIacWont: arg
]

{ #category : #'commands-do' }
TelnetProtocol >> iacDoFlowControl: arg [

	debug ifTrue: [self rcvd: Do with: arg].
]

{ #category : #'commands-do' }
TelnetProtocol >> iacDoNAWS: arg [

	debug ifTrue: [self rcvd: Do with: arg].
	doNAWS := true.
	(cols ~~ 0 and: [rows ~~ 0])	"previous negotiation delayed"
		ifTrue: [self sbWindowSizeSendCols: cols rows: rows]
]

{ #category : #'commands-do' }
TelnetProtocol >> iacDoNewEnvironment: arg [

	debug ifTrue: [self rcvd: Do with: arg].
	self sendIacWont: arg
]

{ #category : #'commands-do' }
TelnetProtocol >> iacDoTerminalSpeed: arg [

	debug ifTrue: [self rcvd: Do with: arg].
	self sendIacWont: arg
]

{ #category : #'commands-do' }
TelnetProtocol >> iacDoTerminalType: arg [

	debug ifTrue: [self rcvd: Do with: arg].
]

{ #category : #'commands-do' }
TelnetProtocol >> iacDoXDisplay: arg [

	debug ifTrue: [self rcvd: Do with: arg].
	self sendIacWont: arg
]

{ #category : #'commands-dont' }
TelnetProtocol >> iacDont: arg [

	debug ifTrue: [self rcvd: Dont with: arg]
]

{ #category : #'commands-dont' }
TelnetProtocol >> iacDontNAWS: arg [

	debug ifTrue: [self rcvd: Dont with: arg].
]

{ #category : #'commands-other' }
TelnetProtocol >> iacIgnored: arg [

	debug ifTrue: [self rcvd: arg].
]

{ #category : #'commands-subnegotiation' }
TelnetProtocol >> iacSB: arg [

	debug ifTrue: [self rcvd: SB with: arg]
]

{ #category : #'commands-subnegotiation' }
TelnetProtocol >> iacSE: arg [

	debug ifTrue: [self rcvd: SE with: arg]
]

{ #category : #'commands-will' }
TelnetProtocol >> iacWill: arg [

	debug ifTrue: [self rcvd: Will with: arg].
	self sendIacDont: arg
]

{ #category : #'commands-will' }
TelnetProtocol >> iacWillEcho: arg [

	debug ifTrue: [self rcvd: Will with: arg].
	self sendIacDo: arg
]

{ #category : #'commands-will' }
TelnetProtocol >> iacWillSuppressGoAhead: arg [

	debug ifTrue: [self rcvd: Will with: arg]
]

{ #category : #debugging }
TelnetProtocol >> initWindow [

	('Connected to ', session endpoint name, '.
') withInternetLineEndings asByteArray do: [:c | self upcall: c]
]

{ #category : #'initialize-release' }
TelnetProtocol >> initialState: aState [

	super initialState: aState.
	self
		setDebug: Debug;
		setDumpNetData: DumpNetData;
		setDumpTermData: DumpTermData.
	"negotiated state"
	doNAWS := false.
	cols := rows := 0.
]

{ #category : #private }
TelnetProtocol >> loadPreferences: dict [

	debug := dict at: #telnetOptionsDebugging
]

{ #category : #protocol }
TelnetProtocol >> note: aSymbol with: anObject [

	super note: aSymbol with: anObject.
	aSymbol == #windowSize		ifTrue: [^self sbWindowSizeSendCols: anObject x rows: anObject y].
	aSymbol == #savePreferences	ifTrue: [^self savePreferences: anObject].
	aSymbol == #loadPreferences	ifTrue: [^self loadPreferences: anObject].
	aSymbol == #restoreDefaults	ifTrue: [^self restoreDefaults]
]

{ #category : #debugging }
TelnetProtocol >> optionName: opt [

	^Options at: opt ifAbsent: [opt printString]
]

{ #category : #debugging }
TelnetProtocol >> rcvd: cmd [

	self debug: 'RCVD ', (self commandName: cmd)
]

{ #category : #debugging }
TelnetProtocol >> rcvd: cmd with: opt [

	self debug: 'RCVD ', (self commandName: cmd), ' ', (self optionName: opt)
]

{ #category : #debugging }
TelnetProtocol >> rcvd: cmd with: opt sub: sub [

	self debug:
		'RCVD ', (self commandName: cmd),
		' ', (self optionName: opt),
		' ', (self subnegotiationName: sub)
]

{ #category : #private }
TelnetProtocol >> restoreDefaults [

	debug := Debug.
	dumpNetData := DumpNetData.
	dumpTermData := DumpTermData.
]

{ #category : #protocol }
TelnetProtocol >> run [
	super run.
	super sessionNote: #oobInlineEndpoint.
	self
		sendIacDo: SuppressGoAhead;
		sendIacWill: TerminalType;
		sendIacWill: NAWS
]

{ #category : #private }
TelnetProtocol >> savePreferences: dict [

	dict at: #telnetOptionsDebugging put: debug
]

{ #category : #'commands-outgoing' }
TelnetProtocol >> sbTerminalTypeSend: arg [

	debug ifTrue: [self rcvd: SB with: TerminalType sub: Send].
	self
		sendIacSb: TerminalType
		isString: (session propertyAt: #terminalType ifAbsent: ['network'])
]

{ #category : #'commands-outgoing' }
TelnetProtocol >> sbWindowSizeSendCols: c rows: r [

	doNAWS
		ifTrue: [self sendIacSb: NAWS isShort: c short: r.  cols := rows := 0.]
		ifFalse: [cols := c.  rows := r]		"delay for future negotiation"
]

{ #category : #'commands-outgoing' }
TelnetProtocol >> sendIac: arg [

	down downcallAll: (ByteArray with: IAC with: arg).
	debug ifTrue: [self sent: arg]
]

{ #category : #'commands-outgoing' }
TelnetProtocol >> sendIacDo: arg [

	down downcallAll: (ByteArray with: IAC with: Do with: arg).
	debug ifTrue: [self sent: Do with: arg]
]

{ #category : #'commands-outgoing' }
TelnetProtocol >> sendIacDont: arg [

	down downcallAll: (ByteArray with: IAC with: Dont with: arg).
	debug ifTrue: [self sent: Dont with: arg]
]

{ #category : #'commands-outgoing' }
TelnetProtocol >> sendIacSb: arg isShort: s1 short: s2 [

	down downcallAll: (ByteArray streamContents: [:str | str
		nextPut: IAC;
		nextPut: SB;
		nextPut: arg;
		nextPut: Is;
		nextPut: (s1 bitAnd: 16rFF); nextPut: (s1 bitShift: -8);
		nextPut: (s2 bitAnd: 16rFF); nextPut: (s2 bitShift: -8);
		nextPut: IAC;
		nextPut: SE]).
	debug ifTrue: [self sent: SB with: arg sub: Is short: s1 short: s2]
]

{ #category : #'commands-outgoing' }
TelnetProtocol >> sendIacSb: arg isString: data [

	down downcallAll: (ByteArray streamContents: [:str | str
		nextPut: IAC;
		nextPut: SB;
		nextPut: arg;
		nextPut: Is;
		nextPutAll: data asByteArray;
		nextPut: IAC;
		nextPut: SE]).
	debug ifTrue: [self sent: SB with: arg sub: Is string: data]
]

{ #category : #'commands-outgoing' }
TelnetProtocol >> sendIacWill: arg [

	down downcallAll: (ByteArray with: IAC with: Will with: arg).
	debug ifTrue: [self sent: Will with: arg]
]

{ #category : #'commands-outgoing' }
TelnetProtocol >> sendIacWont: arg [

	down downcallAll: (ByteArray with: IAC with: Wont with: arg).
	debug ifTrue: [self sent: Wont with: arg]
]

{ #category : #debugging }
TelnetProtocol >> sent: cmd [

	self debug: 'SENT ', (self commandName: cmd)
]

{ #category : #debugging }
TelnetProtocol >> sent: cmd with: opt [

	self debug: 'SENT ', (self commandName: cmd), ' ', (self optionName: opt)
]

{ #category : #debugging }
TelnetProtocol >> sent: cmd with: opt sub: sub short: s1 short: s2 [

	self debug: 'SENT ', (self commandName: cmd),
		' ', (self optionName: opt),
		' ', (self subnegotiationName: sub),
		' ', (s1 bitShift: -8) printString, ' ', (s1 bitAnd: 16rFF) printString, ' (', s1 printString, ')',
		' ', (s2 bitShift: -8) printString, ' ', (s2 bitAnd: 16rFF) printString, ' (', s2 printString, ')'
]

{ #category : #debugging }
TelnetProtocol >> sent: cmd with: opt sub: sub string: str [

	self debug: 'SENT ', (self commandName: cmd),
		' ', (self optionName: opt),
		' ', (self subnegotiationName: sub),
		' "', str, '"'
]

{ #category : #'initialize-release' }
TelnetProtocol >> setDebug: aBoolean [

	debug := aBoolean
]

{ #category : #'initialize-release' }
TelnetProtocol >> setDumpNetData: aBoolean [

	dumpNetData := aBoolean
]

{ #category : #'initialize-release' }
TelnetProtocol >> setDumpTermData: aBoolean [

	dumpTermData := aBoolean
]

{ #category : #debugging }
TelnetProtocol >> subnegotiationName: sub [

	^Subnegotiation at: sub ifAbsent: [sub printString]
]

{ #category : #protocol }
TelnetProtocol >> upcall: aChar [

	dumpNetData ifTrue: [self dump: '<'; dumpHex: aChar; dump: '>'].
	super upcall: aChar
]
