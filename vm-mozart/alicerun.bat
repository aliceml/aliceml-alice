@echo off

set OZ_LOAD=pattern=?{x}=?{x}.ozf;pattern=x-alice:/?{x}=%STOCKHOME%/?{x}.ozf;pattern=x-alice:/?{x}=%STOCKHOME%/?{x};cache=%OZHOME%/cache

set ALICE_LOAD=pattern=x-oz:?{x}=x-oz:?{x};pattern=?{x}=?{x}.ozf;pattern=?{x}=?{x};pattern=x-alice:/?{x}=%STOCKHOME%/?{x}.ozf;pattern=x-alice:/?{x}=%STOCKHOME%/?{x}

set OZ_LOAD=%ALICE_LOAD%;%OZ_LOAD%

ozengine x-alice:/VMMain %1 %2 %3 %4 %5 %6 %7 %8 %9
