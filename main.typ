// SPDX-FileCopyrightText: Copyright (C) Nile Jocson <seiversiana@gmail.com>
// SPDX-License-Identifier: MPL-2.0

#import "@preview/charged-ieee:0.1.4": ieee

#import "@preview/fletcher:0.5.8": diagram, node, edge
#import "@preview/unify:0.7.1": num, qty, qtyrange,

#show: ieee.with(
	title: "PWM Motor Controller",
	authors: (
		(
			name: "Nile Jocson",
			department: [Electrical and Electronics Engineering Institute],
			organization: [University of the Philippines Diliman],
			location: [Quezon City, Philippines],
			email: "nile.xavier.jocson@eee.upd.edu.ph"
		),
	),
	bibliography: bibliography("refs.yaml"),
	figure-supplement: [Fig.],
)

#set figure(placement: top)

#set table(
	columns: (6em, auto),
	align: (left, right),
	inset: (x: 8pt, y: 4pt),
	stroke: (x, y) => if y <= 1 { (top: 0.5pt) },
	fill: (x, y) => if y > 0 and calc.rem(y, 2) == 0  { rgb("#efefef") },
)

#let vstable = table.with(
	columns: (6em, auto),
	align: (x, y) => if x == 0 { left } else { right },
	inset: (x: 8pt, y: 4pt),
	stroke: (x, y) => {
		if x == 0 {
			(right: 0.5pt)
		}
		if y <= 1 {
			(top: 0.5pt)
		}
	},
	fill: (x, y) => if y > 0 and calc.rem(y, 2) == 0  { rgb("#efefef") },
)

#let dtable = table.with(
	columns: (6em, auto),
	align: (left, right),
	inset: (x: 8pt, y: 4pt),
	stroke: (x, y) => {
		if x == 1 {
			(right: 0.5pt)
		}
		if y <= 1 {
			(top: 0.5pt)
		}
	},
	fill: (x, y) => if y > 0 and calc.rem(y, 2) == 0  { rgb("#efefef") },
)



= Source
The Git repository for this project is located at
https://github.com/seiversiana/motor-pwm. Included are the license, source code,
image files, and LTSpice files.



= Specifications
We are tasked with creating a PWM motor controller for a #qty(6, "V"),
size 130 brushed motor, using only BJTs. The input and output specifications of
this system are shown below @f:spec:

$
	V_"CC" = #qty(6, "V") \
	f_"S" = #qty("5.5+-0.1", "kHz") \
	D_"S, max" = #qty("80+-5", "%") \
	D_"S, min" = #qty("50+-5", "%")
$ <f:spec>

The PWM motor controller system shall be constructed using four stages coupled
to each other: an astable multivibrator, a monostable multivibrator, an
emitter follower, and finally a DC chopper. The block diagram of this system is
shown in @d:block.

#figure(
	diagram(
		node-stroke: 1pt,
		node((0, 0.0), [Astable Multivibrator]), edge("-|>"),
		node((0, 0.7), [Monostable Multivibrator]), edge("-|>"),
		node((0, 1.4), [Emitter Follower]), edge("-|>"),
		node((0, 2.1), [DC Chopper])
	),
	caption: [Block diagram of the PWM motor controller system.],
	placement: none
) <d:block>



= Theory
== Astable Multivibrator <s:astable>
The circuit diagram of the astable multivibrator stage is shown in @i:astable.

#figure(
	image("assets/astable.png"),
	caption: [Circuit diagram of the astable multivibrator stage.],
) <i:astable>

In order to design this stage, we first need to choose a transistor. The 2N3904
is a general-purpose low-current switching transistor that is perfect for our
purposes. Its maximum frequency can be calculated from its switching
characteristics from its datasheet @2n3904, as shown below @f:2n3904freq:

$
	f_"max" = 1/(t_"d" + t_"r" + t_"s" + t_"f") = #qty(3.125, "MHz")
$ <f:2n3904freq>

Our needed frequency of #qty(5.5, "kHz") is safely within this limit. Now,
we need to determine the currents and resistances needed to let the transistors of the
astable multivibrator go into saturation. For the 2N3904, we have $V_"CE, sat" = #qty(0.2, "V")$
and $V_"BE, sat" = #qtyrange(0.65, 0.85, "V")$ for the current conditions
$I_"C" = #qty(10, "mA")$ and $I_"B" = #qty(1, "mA")$. Let's assume an average
base saturation voltage $V_"BE, sat" = #qty(0.75, "V")$ instead to simplify
the calculations.

The duty cycle doesn't really matter for this stage, since that will be
governed by the monostable multivibrator. Let's assume a duty cycle of
#qty(50, "%"). This allows us to set $R_"AB1" = R_"AB2" = R_"AB"$,
$R_"AC1" = R_"AC2" = R_"AC"$, and $C_"A1" = C_"A2" = C_"A"$. We can use KVL to
solve for the resistor values, as shown below @f:abase @f:acollector:

$
	V_"CC" - I_"AB" R_"AB" - V_"BE, sat" = 0 \
	R_"AB" = (V_"CC" - V_"BE, sat")/I_"AB" = #qty(5.25, "kO")
$ <f:abase>

$
	V_"CC" - I_"AC" R_"AC" - V_"CE, sat" = 0 \
	R_"AC" = (V_"CC" - V_"CE, sat")/I_"AC" = #qty(580, "O")
$ <f:acollector>

Now, we can solve for the needed capacitors based on our frequency
specification $f_"S"$ @astable, as shown below @f:acap:

$
	f_"S" = 1/(2 R_"AB" C_"A" ln 2) \
	C_"A" = 1/(2 R_"AB" f_"S" ln 2) = #qty(24.98, "nF")
$ <f:acap>

== Monostable Multivibrator
The circuit diagram of the monostable multivibrator stage coupled to the astable
multivibrator stage is shown in @i:monostable.

#figure(
	image("assets/monostable.png"),
	caption: [
		Circuit diagram of the monostable multivibrator stage coupled to the
		astable multivibrator stage.
	]
) <i:monostable>

For this stage, we'll use the 2N3904 again for the same reasons as in @s:astable.
We can also use $R_"MC1" = R_"MC2" = R_"AC"$ since the
currents needed to saturate the transistors hasn't changed. In this stage, varying
the duty cycle is done by varying $R_"MB1"$; a higher resistance corresponds to a
higher duty cycle and vice-versa. In order to keep $Q_"M2"$ in saturation, we set
$R_"MB1, max" = R_"AB"$ to get our maximum duty cycle $D_"S, max" = #qty(80, "%")$.
Now we can calculate for $C_"M"$ @f:mcapd @f:mcapv:

$
	T_"S, on" =& R_"MB1, max" dot C_"M" ln 2 \
	T_"S" D_"S, max" =& R_"MB1, max" dot C_"M" ln 2 \
	f_"S" =& D_"S, max"/(R_"MB1, max" dot C_"M" ln 2)
$ <f:mcapd>

$
	C_"M" = D_"S, max"/(R_"MB1, max" dot f_"S" ln 2) = #qty(39.97, "nF")
$ <f:mcapv>

Next, solving for the needed $R_"MB1, min"$ to get the minimum duty cycle
$D_"S, min" = #qty(50, "%")$ @f:mminbase:

$
	R_"MB1, min" = D_"S, min"/(C_"M" f_"S" ln 2) = #qty(3.28, "kO")
$ <f:mminbase>

From this, we have a base resistance difference of $Delta R_"MB1" = #qty(1.97, "kO")$.
An easy way to get this range without needing a precision potentiometer is by using
the resistor network shown in @i:rmb1.

#figure(
	image("assets/rmb1.png"),
	caption: [Resistor network equivalent of $R_"MB1"$.]
) <i:rmb1>

Here, $R_"P"$ is the potentiometer resistance, where $R_"P, max" >> Delta R_"MB1"$
and  $R_"P, min" = #qty(0, "O")$. This gives us the following behavior for $R_"MB1"$
@f:rmb1:

$
	R_"MB1"
		=& R_"MB1, min" + (Delta R_"MB1" dot R_"P")/(Delta R_"MB1" + R_"P") \
		=& cases(
			R_"MB1, max" &\,quad R_"P" = R_"P, max",
			R_"MB1, min" &\,quad R_"P" = R_"P, min"
		)
$ <f:rmb1>

When $R_"P" = R_"P, max"$, $R_"P"$ effectively becomes an open, eliminating itself
from the circuit. When $R_"P" = R_"P, min"$, $R_"P"$ becomes a short, eliminating
$Delta R_"MB1"$ from the circuit. Note however, that with a higher range for $R_"P"$,
the transition between $R_"MB1, min"$ and $R_"MB1, max"$ becomes less and less linear, assuming
that $R_"P"$ varies linearly across one full turn.
This paper will use a potentiometer with a range
of $R_"P" = #qtyrange(0, 100, "kO")$, as this is what was available on hand.

Next, we can solve for $R_"MB2"$ by recognizing that in order for $Q_"M1"$ to stay
in saturation, it needs to see a resistance of $R_"AB"$ from its base. Solving for
$R_"MB2"$ @f:rmb2:

$
	R_"MB2" = R_"AB" - R_"MC2" = #qty(4.67, "kO")
$ <f:rmb2>

Finally, we need to determine the values for the coupling. First, we need to select
the diode model for $D_"T"$. The 1N4148 is a high-speed switching diode which is
perfect for this purpose. Its maximum frequency can be solved from its reverse
recovery time @1n4148, as shown below @f:1n4148freq:

$
	f_"max" = 1/t_"rr" = #qty(250, "MHz")
$ <f:1n4148freq>

Our needed frequency is safely within this limit. Next, we need to solve for $C_"T"$
and $R_"T"$. Note that we are triggering this stage using the falling edge of the
astable multivibrator stage. This gives us a negative voltage at the base of $Q_"M2"$,
causing it to turn off. $Q_"M1"$ and $Q_"M2"$ then turns on, which means that we have
an RC circuit with $R_"T"$, $R_"MB1"$, and $C_"T"$ that discharges through $Q_"A2"$.

We want the negative pulse to last long enough to trigger the monostable multivibrator,
but also we want it to be short enough that it doesn't retrigger it. A good baseline
for this would be #qty(10, "%") of $T_"off"$. Let's use the formula below to calculate
for this time @f:2rc:

$
	T = 2 R C
$ <f:2rc>

This gets us #qty(86.5, "%") of the way to completely discharging the capacitor,
which is probably good enough for this calculation. Note that $R$ here would be
the parallel resistors $R_"T"$ and $R_"MB2"$  #footnote[This is a massive error;
$R_"T"$ and $R_"MB2"$ are not in parallel at all. However, the circuit was
finalized and soldered long before I caught this error. I won't be correcting it;
what's done is done, and I have spent way too much time on this project already.],
and we will be using $R_"MB2" = R_"MB2, max"$ so that we'll be solving for the
maximum negative pulse time. Setting up the equation for $R_"T"$ and $C_"T"$ @f:ctrtd:

$
	#qty(5, "%")/f_"S" =& 2 C_"T" dot (R_"T" R_"MB2, max")/(R_"T" + R_"MB2, max")
$ <f:ctrtd>

There isn't really a single value for $C_"T"$ and $R_"T"$ since we only have one
equation. We'll set $C_"T" = #qty(15, "nF")$ since this is what was available on
hand, and solve for $R_"T"$. We get @f:rt:

$
	R_"T" = #qty(321.59, "O")
$ <f:rt>

== Emitter Follower and DC Chopper
The circuit diagram of the DC chopper stage coupled to the emitter follower and
monostable multivibrator stages is shown in @i:chopper.

#figure(
	image("assets/chopper.png"),
	caption: [
		Circuit diagram of the DC chopper stage coupled to the emitter follower and
		monostable multivibrator stages.
	]
) <i:chopper>

In order to analyze this stage, we first need to know the collector current of $Q_"D"$.
A common stall current for a #qty(6, "V"), size 130 brushed motor is around
#qty(800, "mA"), which will be the maximum collector current of $Q_"D"$. For this
current, we need a power transistor. One such transistor is the TIP31C, an NPN
transistor which can handle up to #qty(3, "A") of collector current @tip31c, which
is more than enough for our needs.

In order to get this current, we need to saturate the transistor by forcing a beta
value of $beta = 10$ @tip31c. This means that $I_"B" = I_"C"/10 = #qty(80, "mA")$.
We also have $V_"BE, sat" = #qty(0.7, "V")$ and $V_"CE, sat" = #qty(0.25 ,"V")$ in
these conditions.

Our monostable multivibrator won't be able to supply this amount of current, so we'll
need to use an emitter follower in between the two stages. This is perfect as it has
a high impedance input and a low impedance output, meaning that it can drive the DC
chopper using the output signal from the monostable multivibrator.

The 2N3904 is not suitable here as the collector current that we will need is almost
half of its maximum rating of #qty(200, "mA") @2n3904, which risks overheating.
Instead, we will be using the 2N4401, which is also a general-purpose switching
transistor, rated for collector current up to #qty(600, "mA") @2n4401. Let's set
the collector current of $Q_"E"$ to be #qty(100, "mA"), so that we have more than
enough current at the emitter to drive the DC chopper.

Note that our emitter follower stage won't be going into saturation; it will only
sit inside forward-active. For our collector current, the closest beta is $beta = 80$
with $V_"CE" = #qty(1, "V")$. Therefore, we will need a base current
$I_"B" = #qty(1.25, "mA")$ for the emitter follower. Now, we can solve for
$I_"E"$, $R_"EE"$, and $R_"DB"$. Solving for $I_"E"$ @f:eemitter:

$
	I_"E" =& I_"B" + I_"C" = (81 I_"C")/80 = #qty(101.25, "mA")
$ <f:eemitter>

Doing KCL on the emitter node gives us the current through $R_"EE"$ @f:ereei:

$
	I_"EE" = I_"E" - I_"DB" = #qty(21.25, "mA")
$ <f:ereei>

Solving for the voltage on the emitter node @f:evoltage:

$
	V_"E" = V_"CC" - V_"CE" = #qty(5, "V")
$ <f:evoltage>

With all of this, we can solve for $R_"EE"$ and $R_"DB"$, as shown below @f:eree
@f:drdb:

$
	R_"EE" = V_"E"/I_"EE" = #qty(235.29, "O")
$ <f:eree>

$
	V_"CC" - V_"CE" - I_"DB" R_"DB" - V_"BE, sat" = 0 \
	R_"DB" = (V_"CC" - V_"CE" - V_"BE, sat")/I_"DB" = #qty(53.75, "O")
$ <f:drdb>

Finally, we can solve for the needed base resistor $R_"EB"$. This can be done by
doing KCL on the output node of the monostable multivibrator stage @f:ereb:

$
	I_"MC2" = I_"MB2" + I_"EB" = #qty(2.25, "mA") \
	V_"out, M" = V_"CC" - I_"MC2" R_"MC2" = #qty(4.69, "V") \
	R_"EB" = V_"out, M"/I_"EB" = #qty(3.75, "kO")
$ <f:ereb>

The last thing to do is to choose the model for the flyback diode $D_"F"$. We'll
use the 1N4007 rectifier diode, as it has a maximum surge current of #qty(30, "A")
@1n4007, which is much higher than the flyback current it will experience with
regular use.

The full theoretical circuit diagram is shown in @i:fulltheoretical. A full list
of the component values and models is shown in @t:fulltheoretical.

#figure(
	image("assets/fulltheoretical.png"),
	caption: [Full diagram of the theoretical circuit.],
	scope: "parent"
) <i:fulltheoretical>

#figure(
	dtable(
		columns: 4,
		table.header[Component][Value/Model][Component][Value/Model],
		$Q_"A1"$       , [2N3904],
		$Q_"A2"$       , [2N3904],
		$Q_"M1"$       , [2N3904],
		$Q_"M2"$       , [2N3904],
		$Q_"E"$        , [2N4401],
		$Q_"D"$        , [TIP31C],
		$D_"T"$        , [1N4148],
		$D_"F"$        , [1N4007],
		$R_"AC1"$      , qty(580, "O"),
		$R_"AC2"$      , qty(580, "O"),
		$R_"AB1"$      , qty(5.25, "kO"),
		$R_"AB2"$      , qty(5.25, "kO"),
		$R_"T"$        , qty(321.59, "O"),
		$R_"MC1"$      , qty(580, "O"),
		$R_"MC2"$      , qty(580, "O"),
		$R_"MB1, min"$ , qty(3.28, "kO"),
		$Delta R_"MB1"$, qty(1.97, "kO"),
		$R_"P"$        , qtyrange(0, 100, "kO"),
		$R_"MB2"$      , qty(4.67, "kO"),
		$R_"EE"$       , qty(235.29, "O"),
		$R_"EB"$       , qty(3.75, "kO"),
		$R_"DB"$       , qty(53.75, "O"),
		$C_"A1"$       , qty(24.98, "nF"),
		$C_"A2"$       , qty(24.98, "nF"),
		$C_"T"$        , qty(15, "nF"),
		$C_"M"$        , qty(39.97, "nF"),
		$M$            , [#qty(6, "V") size 130 \ brushed DC motor]
	),
	caption: [Component Values/Models of the Theoretical Circuit]
) <t:fulltheoretical>



= Simulation
== Theoretical Values
In order to simulate the PWM motor controller system, we will use LTSpice. First,
we will be simulating the circuit using the theoretical values given in
@t:fulltheoretical. For all simulations, we will step $R_"P"$ through its minimum
and maximum values. However, LTSpice doesn't allow stepping with #qty(0, "O")
resistors, so we'll instead use a minimum potentiometer resistance of
$R_"P, min" = #qty(1, "nO")$.

Note that the motor was replaced by a #qty(7.19, "O") resistor. This was calculated
by doing KVL through the motor and $Q_"D"$, and by taking into account the motor
stall current of #qty(800, "mA") @f:motorresist:

$
	V_"CC" - I_"stall" R_"M" - V_"CE, sat" = 0 \
	R_"M" = (V_"CC" - V_"CE, sat")/I_"stall" = #qty(7.19, "O")
$ <f:motorresist>

With the theoretical component values, we get the measurements shown in @t:theoretical.

#figure(
	vstable(
		columns: 3,
		table.header[Measurement][$R_"P, min"$][$R_"P, max"$],
		[Frequency] , qty(5.21, "kHz"), qty(5.21, "kHz"),
		[Duty Cycle], qty(52.33, "%") , qty(75.5, "%")
	),
	caption: [Simulation Measurements of the Theoretical Circuit]
) <t:theoretical>

Sadly, our frequencies here are out of spec by about #qty(300, "Hz"). Our duty cycles
are okay, but as much as possible we want them to be as close as possible to the
specifications, so that real life tolerances won't nudge them out of spec.

One problem is that the equation for the frequency of an astable multivibrator is
just an ideal model, which assumes that the transistors and capacitors are ideal.
It also doesn't take into account that the astable multivibrator might be loaded;
in our case, it is loaded by the trigger of the monostable multivibrator, which
may have caused the frequencies to drift.

Our duty cycles are a lot closer, but they can be better. A probable cause for
this is the fact that we don't actually get $R_"MB1" = R_"MB1, max"$ when
$R_"P" = R_"P, max"$ since that will only happen when $R_"P, max"$ is infinite.
The monostable multivibrator is also loaded by the emitter follower in our case,
however not by much.

== Standardized Values
In order to fix the discrepancies with the output frequency and duty cycle, we'll
first pick standard values for the capacitors. Note that when maintaining on and
off times, capacitance is inversely proportional to resistance. We can only decrease
the resistance of the timing resistors since we don't want to nudge the transistors
out of saturation, so we'll need to use the closest standard capacitor that's larger
than the theoretical value.

For the timing resistors, the only thing we can do at this point is to try different
standard values (or combinations thereof) that will make the frequency and duty cycle
as close to the specifications as possible. For all other components, we can just use
the closest standard values since they don't matter that much for the frequency and
duty cycle specifications. The list of standardized component values is shown in
@t:standardcomponents. With the standardized component values, we get the measurements
shown in @t:standardmeasurements.

#figure(
	dtable(
		columns: 4,
		table.header[Component][Value][Component][Value],
		$R_"AB1"$, qty(4.62, "kO"),
		$R_"AB2"$, qty(4.62, "kO"),
		$R_"AC1"$, qty(560, "O"),
		$R_"AC2"$, qty(560, "O"),
		$R_"T"$  , qty(330, "kO"),
		$R_"MC1"$, qty(560, "O"),
		$R_"MC2"$, qty(560, "O"),
		$R_"MB2"$, qty(4.7, "kO"),
		$R_"EB"$ , qty(3.6, "kO"),
		$R_"EE"$ , qty(240, "O"),
		$R_"DB"$ , qty(51, "O"),
	),
	caption: [Component Values of the Standardized Circuit]
) <t:standardcomponents>

#figure(
	vstable(
		columns: 3,
		table.header[Measurement][$R_"P, min"$][$R_"P, max"$],
		[Frequency] , qty(5.49, "kHz"), qty(5.49, "kHz"),
		[Duty Cycle], qty(50.11, "%") , qty(80.2, "%")
	),
	caption: [Simulation Measurements of the Standardized Circuit]
) <t:standardmeasurements>

These measurements are now well within the specifications. However, before we move
on, let's check the power dissipation of the resistors. The resistor with the
highest power dissipation is $R_"DB"$ at around #qty(106.54, "mW"). Because of this,
let's use a #qty(0.5, "W") resistor for $R_"DB"$, just to be safe and prevent
overheating.



= Actual Construction
== Breadboard Construction
For the actual construction, some components were not able to be procured, so they
were replaced with components of similar values. Those components and their values
are shown in @t:replaced.

#figure(
	table(
		columns: 2,
		table.header[Component][New Value/Model],
		$R_"EB"$, [#qty(3.3, "kO") Resistor],
		$R_"DB"$, [#qty(50, "O") Resistor, #qty(0.5, "W")]
	),
	caption: [List of Replacement Components]
) <t:replaced>

The first version of the breadboard was made at home without access to an oscilloscope or power
supply, shown in @i:breadboard1. In order to find the frequency, the output was
connected to an old pair of headphones, then a tone generator was used to match
the sound from the headphones. This showed that the frequency was around #qty(5.3, "kHz"),
which is quite a difference from the expected frequency. A probable cause for this
was the voltage drop of the four #qty(1.5, "V") carbon-zinc batteries when trying
to supply the needed current of the circuit.

#figure(
	rotate(-90deg, image("assets/breadboard1.jpg"), reflow: true),
	caption: [First version of the breadboard construction of the PWM motor controller.]
) <i:breadboard1>

The second version of the breadboard was made in the lab, this time with access to
an oscilloscope and power supply, shown in @i:breadboard2. As suspected, the frequency was sagging due to
the wrong kind of batteries, as the frequency was now #qty(5.4, "kHz") using the
power supply. However, this is still not the expected frequency, so the timing resistors
of the astable multivibrator stage had to be changed. This is probably due to the
timing capacitors, which have tolerances of #qty("+-10", "%"). The duty cycle was
also not in the expected range; the maximum potentiometer resistance was causing
double-triggering issues, so the timing resistors of the monostable multivibrator
stage also had to be changed. Again, this is probably due to the #qty("+-5", "%")
tolerance of its timing capacitor.

#figure(
	image("assets/breadboard2.jpg"),
	caption: [Second version of the breadboard construction of the PWM motor controller.]
) <i:breadboard2>

The list of new values for the timing components are shown in @t:changed. These
new timing resistor values finally gives the expected frequency and duty cycles.

#figure(
	table(
		columns: 2,
		table.header[Component][New Value/Model],
		$R_"AB1"$      , [#qty(4.4, "kO") Resistor],
		$R_"AB2"$      , [#qty(4.62, "kO") Resistor],
		$Delta R_"MB1"$, [#qty(2.25, "kO") Resistor],
	),
	caption: [List of Changed Components]
) <t:changed>

== Soldered Construction
The soldered version of the PWM motor controller made on a perfboard is shown in
@i:soldered. The carbon-zinc batteries were replaced with alkaline batteries with
the same voltage for the power supply, as these can supply the needed current without
dropping voltage. The frequency and duty cycle remain unchanged and in the specifications.

#figure(
	rotate(-90deg, image("assets/soldered.jpg"), reflow: true),
	caption: [Soldered construction of the PWM motor controller.]
) <i:soldered>



= Conclusion
This project was quite the endeavor; I wasn't expecting this project to take more than a month
of my time. The first week was spent pursuing a prototype without doing circuit
analysis, which was very incompetent of me. I also painstakingly created a perfboard
prototype of the uncalculated circuit using a broken soldering iron for two whole
days without sleeping, which did not work; I don't know why I even did this at all.
This prototype was incredibly ugly; my naïve method of putting multiple component
legs in one hole made soldering very hard, and in some cases, the copper pads were
separating from the base because of this. I used bare copper wire for some reason,
which also made the circuit unsafe.

The next few weeks were used doing the project the correct way, I started this documentation
as a way to list down the calculated values of the circuit, then I did the simulations
and prototyped the circuit on the breadboard. After getting approval, I moved on
with soldering. The failed attempt was a good practice, as it made me come up with
my new method of just solder bridging the leads. I also bought a new soldering iron
and a chisel tip, which helped immensely. The resulting prototype was much prettier,
and it is the one shown in @i:soldered.

With the many, many prototypes of this circuit, I made quite a lot of trips to DEECO
to get the right components. There were some cases where I found out only at home
that I received a broken capacitor or transistor. This pushed me to buy two of each
component listed in @t:fulltheoretical for redundancy. I also relented and bought
a box of 600 metal film resistors of different values online, since DEECO rarely had
the very _standard_ resistors that I needed.

I can think of multiple different conclusions for this project:
+ The right way is significantly better and less painful than the seemingly easier
	but incorrect way.
+ Practice first before trying to do something important for the first time.
+ Cramming something using the wrong or broken tools will only lead to suffering.
+ Have a plan for when the shop doesn't have the components you need.
+ If you can't test the components in the shop, buy two or more for redundancy.
+ Theoretical values will differ from simulation values, which will differ from
	real-life values.
+ Manage your time wisely.

With this, I have completed the first half of my journey in EEE 148.
