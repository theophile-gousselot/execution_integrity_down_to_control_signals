/**************************************************************************/
/*                                                                        */
/*  This file is part of FISSC.                                           */
/*                                                                        */
/*  You can redistribute it and/or modify it under the terms of the GNU   */
/*  Lesser General Public License as published by the Free Software       */
/*  Foundation, version 3.0.                                              */
/*                                                                        */
/*  It is distributed in the hope that it will be useful,                 */
/*  but WITHOUT ANY WARRANTY; without even the implied warranty of        */
/*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         */
/*  GNU Lesser General Public License for more details.                   */
/*                                                                        */
/*  See the GNU Lesser General Public License version 3.0                 */
/*  for more details (enclosed in the file LICENSE).                      */
/*                                                                        */
/**************************************************************************/

/*$
  @name = VerifyPIN_0
  @feature = verifyPIN
  @fault-model = test-inversion
  @attack-scenario = oracle
  @countermeasure = none
  @maintainers = Etienne Boespflug, VERIMAG
  @authors = Lionel Rivière, SERTIF Consortium
  @version 2.2
*/


#include <stdio.h>

#include "interface.h"
#include "commons.h"
#include "types.h"
#include "lazart.h"

// global variables definition
BOOL g_authenticated;
SBYTE g_ptc;
UBYTE g_countermeasure;
UBYTE g_userPin[PIN_SIZE];
UBYTE g_cardPin[PIN_SIZE];

//BOOL verifyPIN(void);

BOOL byteArrayCompare(UBYTE* a1, UBYTE* a2, UBYTE size)
{
    int i;
    for(i = 0; i < size; i++) {
        if(a1[i] != a2[i]) {
            return 0;
        }
    }
    return 1;
}

BOOL verifyPIN() {
    g_authenticated = 0;

    if(g_ptc > 0) {
        if(byteArrayCompare(g_userPin, g_cardPin, PIN_SIZE) == 1) {
            g_ptc = 3;
            g_authenticated = 1; // Authentication();
            return 1;
        } else {
            g_ptc--;
            return 0;
        }
    }

    return 0;
}

void initialize()
{
   // local variables
   int i;
   // global variables initialization
   g_authenticated = 0;
   g_ptc = 3;
   g_countermeasure = 0;
   // card PIN = 1 2 3 4 5...
   for (i = 0; i < PIN_SIZE; ++i) {
       g_cardPin[i] = i+1;
   }
   // user PIN = 0 0 0 0 0...
   for (i = 0 ; i < PIN_SIZE; ++i) {
       g_userPin[i] = 0;
   }
}



int main()
{
    initialize();
    verifyPIN();
    LAZART_ORACLE(oracle());

    printf("[@] g_countermeasure = %i, g_authenticated = %x, g_ptc = %i\n", g_countermeasure, g_authenticated, g_ptc);
    return 0;
}
