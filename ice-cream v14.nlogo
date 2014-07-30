; Todo van Pierre:
;3. vorige stappen laten zien

globals [
  turn
  mouse-selection
  nash-eq?
  pos1
  pos2
  pos3
  pos4
  pos5
  setpos?
]

breed [ customers customer ]
breed [ sellers seller ]

customers-own [ my-sellers ]
sellers-own [ sales moved? ]

to setup

  clear-all
  
  set mouse-selection nobody
  
  set nash-eq? false

  ask n-of sellers? patches [
    sprout-sellers 1 [
      set shape "circle"
      set size 1
      set sales 0
      set color item who base-colors      
      set label who
      set moved? true
    ]
  ]

  
  if setpos? = true [
    
    ask seller 0 [ set xcor         pos1 mod ( max-pxcor + 1 )
                   set ycor floor ( pos1 / ( max-pxcor + 1 ) ) ]    

    ask seller 1 [ set xcor         pos2 mod ( max-pxcor + 1 )
                   set ycor floor ( pos2 / ( max-pxcor + 1 ) ) ]    

    if sellers? > 2 [
      ask seller 2 [ set xcor         pos3 mod ( max-pxcor + 1 )
                     set ycor floor ( pos3 / ( max-pxcor + 1 ) ) ]    
    ]
    
    if sellers? > 3 [
      ask seller 3 [ set xcor         pos4 mod ( max-pxcor + 1 )
                     set ycor floor ( pos4 / ( max-pxcor + 1 ) ) ]
    ]
    
    if sellers? > 4 [
      ask seller 4 [ set xcor         pos5 mod ( max-pxcor + 1 )
                     set ycor floor ( pos5 / ( max-pxcor + 1 ) ) ]    
    ]
    
  ]
        
  ask patches [
    sprout-customers 1 [
      set shape "circle"
      set size 0.75
      set color white
      set my-sellers sellers
    ]
  ]
         
  set turn 0

  reset-ticks
    
end

to take-turns
  ask sellers with [ who = turn ] [ relocate ]
  ask customers [ buy-ice ]
  set turn turn + 1
  set turn turn mod count sellers
  ask sellers [ set sales 0 ]
  output-payoffs
  set nash-eq? nash-eq
  if stop? and nash-eq? [ stop ] 
  tick
end

; customer procedure
to buy-ice

  let sorted sort-by [ distance ?1 < distance ?2 ] sellers

  let closest first sorted
  let distance-closest distance closest
  
  let selected (list )

  foreach sorted [
    if(distance ? = distance-closest)[
      set selected lput ? selected
    ]    
  ]

  ifelse length selected > 1 [ set shape "triangle" ] [ set shape "circle" ]
  
  let demand spatial-demand distance closest
  
  foreach selected [ ask ? [ set sales sales + ( demand / length selected ) ] ]
  
  ifelse demand > 0 [ set color [color] of closest ] [ set color white ]
  
end

; ga iedere plaats langs
; vraag aan iedere klant vanuit deze plaats, wie heb je liever?
; kies de plaats waar de klanten het meest bij jou verkopen

; seller procedure
to relocate
  
  set moved? false
  
  let current-location patch-here
  let current-score my-payoff
  let best-score current-score
  let best-location patch-here
  
  let interesting-locations false
  
  ifelse local?
    [ set interesting-locations patches in-radius vision ]
    [ set interesting-locations patches ]

  foreach sort interesting-locations [
    let loop-location ?

    move-to loop-location
        
    let loop-score false

    ifelse social?
      [ set loop-score total-payoffs ]
      [ set loop-score my-payoff ]
    
    if loop-score > best-score [
      set best-score loop-score
      set best-location loop-location
    ]        
  ]

  ifelse best-location != current-location [
    move-to best-location
    set moved? true
  ][
    move-to current-location
    set moved? false
  ]
  
end

to-report my-payoff
  report payoff who
end

to-report payoff [ id ]
  
  ask customers [ buy-ice ]

  let s mean [ sales ] of sellers with [ who = id ]
  
  ask sellers [ set sales 0 ]  
  
  report s
  
end

to-report payoffs
  let payoff-list (list)
  
  let i 0
  
  repeat sellers? [
    set payoff-list lput ( payoff i ) payoff-list
    set i i + 1
  ]
    
  report payoff-list
  
end

to mouse

  ifelse mouse-down? [

    let x round mouse-xcor
    let y round mouse-ycor
  
    if mouse-selection = nobody [    
      set mouse-selection min-one-of sellers [distancexy x y]
    ] 

    ask mouse-selection [ setxy x y ]

  ][
    set mouse-selection nobody
  ]
  
  every 0.1 [ output-payoffs ]
  
end

to-report spatial-demand [ d ]
  report w ^ d
end

to-report nash-eq
  
  ; if no one moved, we have a Nash equilibrium, otherwise not
  ifelse count sellers with [ moved? = true ] = 0
    [ report true ][ report false ]
  
end

; reports distance between 2 sellers (only when there are 2 sellers in game!)
to-report dist-n2
  
  ; report false when there are more or less than 2 sellers in game
  if count sellers != 2 [ report false ]
  
  let d false
  
  ask one-of sellers [ set d distance one-of other sellers ]

  report d
  
end

to output-payoffs
  let payoff-list payoffs
  clear-output
  let i 0
  let t 0
  foreach payoff-list [
    output-print (word i "   " precision ? 2)
    set t t + ?
    set i i + 1
  ]
  output-print "+   ____"
  output-print (word "    " precision t 2)
end

to-report total-payoffs
  report sum payoffs
end
@#$#@#$#@
GRAPHICS-WINDOW
131
10
381
281
-1
-1
24.0
1
10
1
1
1
0
0
0
1
0
9
0
9
1
1
1
ticks
30.0

BUTTON
12
11
122
44
NIL
setup
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

SLIDER
12
77
122
110
w
w
0
1
0.5
0.1
1
NIL
HORIZONTAL

BUTTON
12
143
122
176
next
take-turns
NIL
1
T
OBSERVER
NIL
N
NIL
NIL
1

BUTTON
12
44
122
77
NIL
mouse
T
1
T
OBSERVER
NIL
M
NIL
NIL
1

BUTTON
12
176
122
209
go
take-turns
T
1
T
OBSERVER
NIL
G
NIL
NIL
1

SLIDER
12
110
122
143
sellers?
sellers?
1
5
3
1
1
NIL
HORIZONTAL

OUTPUT
392
11
531
202
12

SWITCH
442
247
532
280
stop?
stop?
0
1
-1000

SWITCH
442
214
532
247
local?
local?
0
1
-1000

INPUTBOX
392
214
442
280
vision
1
1
0
Number

SWITCH
12
209
122
242
social?
social?
1
1
-1000

@#$#@#$#@
## WHAT IS IT?

This section could give a general understanding of what the model is trying to show or explain.

## HOW IT WORKS

This section could explain what rules the agents use to create the overall behavior of the model.

## HOW TO USE IT

This section could explain how to use the model, including a description of each of the items in the interface tab.

## THINGS TO NOTICE

This section could give some ideas of things for the user to notice while running the model.

## THINGS TO TRY

This section could give some ideas of things for the user to try to do (move sliders, switches, etc.) with the model.

## EXTENDING THE MODEL

This section could give some ideas of things to add or change in the procedures tab to make the model more complicated, detailed, accurate, etc.

## NETLOGO FEATURES

This section could point out any especially interesting or unusual features of NetLogo that the model makes use of, particularly in the Procedures tab.  It might also point out places where workarounds were needed because of missing features.

## RELATED MODELS

This section could give the names of models in the NetLogo Models Library or elsewhere which are of related interest.

## CREDITS AND REFERENCES

This section could contain a reference to the model's URL on the web if it has one, as well as any other necessary credits or references.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.0.3
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experimentH1" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>take-turns</go>
    <timeLimit steps="100"/>
    <exitCondition>nash-eq = true</exitCondition>
    <metric>ticks</metric>
    <metric>nash-eq</metric>
    <steppedValueSet variable="w" first="0" step="0.1" last="1"/>
    <steppedValueSet variable="max-pxcor" first="2" step="2" last="20"/>
  </experiment>
  <experiment name="experimentH2" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>take-turns</go>
    <timeLimit steps="100"/>
    <exitCondition>nash-eq = true</exitCondition>
    <metric>nash-eq</metric>
    <metric>dist-n2</metric>
    <steppedValueSet variable="w" first="0" step="0.01" last="1"/>
    <enumeratedValueSet variable="max-pxcor">
      <value value="499"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-pycor">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-sellers">
      <value value="2"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experimentH3" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>take-turns</go>
    <timeLimit steps="25"/>
    <exitCondition>nash-eq = true</exitCondition>
    <metric>nash-eq</metric>
    <steppedValueSet variable="w" first="0" step="0.1" last="1"/>
    <enumeratedValueSet variable="number-of-sellers">
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="H1deterministic" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>take-turns</go>
    <timeLimit steps="2"/>
    <exitCondition>ticks = 2</exitCondition>
    <metric>nash-eq?</metric>
    <enumeratedValueSet variable="sellers?">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stop?">
      <value value="false"/>
    </enumeratedValueSet>
    <steppedValueSet variable="w" first="0" step="0.1" last="1"/>
    <enumeratedValueSet variable="vision">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="local?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="setpos?">
      <value value="true"/>
    </enumeratedValueSet>
    <steppedValueSet variable="pos1" first="0" step="1" last="19"/>
    <steppedValueSet variable="pos2" first="0" step="1" last="19"/>
  </experiment>
  <experiment name="H2deterministic" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>take-turns</go>
    <timeLimit steps="2"/>
    <exitCondition>ticks = 2</exitCondition>
    <metric>nash-eq?</metric>
    <metric>dist-n2</metric>
    <metric>total-payoffs</metric>
    <enumeratedValueSet variable="payoffs?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-sellers">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stop?">
      <value value="false"/>
    </enumeratedValueSet>
    <steppedValueSet variable="w" first="0" step="0.1" last="1"/>
    <enumeratedValueSet variable="vision">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="local-optimum?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="monte-carlo?">
      <value value="false"/>
    </enumeratedValueSet>
    <steppedValueSet variable="pos1" first="0" step="1" last="19"/>
    <steppedValueSet variable="pos2" first="0" step="1" last="19"/>
  </experiment>
  <experiment name="H2monte-carlo" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>take-turns</go>
    <timeLimit steps="25"/>
    <exitCondition>nash-eq?</exitCondition>
    <metric>nash-eq?</metric>
    <metric>[ xcor ] of seller 0</metric>
    <metric>[ xcor ] of seller 1</metric>
    <enumeratedValueSet variable="payoffs?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-sellers">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stop?">
      <value value="false"/>
    </enumeratedValueSet>
    <steppedValueSet variable="w" first="0" step="0.1" last="1"/>
    <enumeratedValueSet variable="vision">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="local-optimum?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="monte-carlo?">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="H3deterministic" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>take-turns</go>
    <timeLimit steps="2"/>
    <exitCondition>ticks = 2</exitCondition>
    <metric>nash-eq?</metric>
    <enumeratedValueSet variable="payoffs?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stop?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="monte-carlo?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vision">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="local-optimum?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-sellers">
      <value value="2"/>
    </enumeratedValueSet>
    <steppedValueSet variable="w" first="0" step="0.2" last="1"/>
    <steppedValueSet variable="pos1" first="0" step="1" last="99"/>
    <steppedValueSet variable="pos2" first="0" step="1" last="99"/>
  </experiment>
  <experiment name="H3_social_optimum" repetitions="25" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>take-turns</go>
    <timeLimit steps="10"/>
    <metric>[xcor] of seller 0</metric>
    <metric>[xcor] of seller 1</metric>
    <enumeratedValueSet variable="monte-carlo?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-sellers">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="local-optimum?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-optimum?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stop?">
      <value value="false"/>
    </enumeratedValueSet>
    <steppedValueSet variable="w" first="0.1" step="0.1" last="0.9"/>
    <enumeratedValueSet variable="min-pxcor">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-pycor">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-pxcor">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-pycor">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 1.0 0.0
0.0 1 1.0 0.0
0.2 0 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
