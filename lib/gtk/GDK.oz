%%%
%%% Authors:
%%%   Thorsten Brunklaus <brunklaus@ps.uni-sb.de>
%%%
%%% Copyright:
%%%   Thorsten Brunklaus, 2000
%%%
%%% Last Change:
%%%   $Date$ by $Author$
%%%   $Revision$
%%%

functor
import
   GTKCoreComponent('GTKCore$' : GTKCore) at 'GTKCore'
   Native at 'x-oz://system/GDK.so{native}'
export
   'GDK$' : GDK
define
   %% Import Core Definitions
   PointerToObject      = GTKCore.pointerToObject
   ObjectToPointer      = GTKCore.objectToPointer
   RemoveObject         = GTKCore.removeObject
   VaArgListToOzList    = GTKCore.vaArgListToOzList

   SignalConnect        = GTKCore.signalConnect
   SignalDisconnect     = GTKCore.signalDisconnect
   SingalHandlerBlock   = GTKCore.signalHandlerBlock
   SingalHandlerUnblock = GTKCore.singalHandlerUnblock
   SingalEmit           = GTKCore.signalEmit

   %% Insert autogenerated Function Wrapper
   \insert 'GDKWrapper.oz'

   %% Insert autogenerated Functor Interface
   \insert 'GDKExport.oz'
end
