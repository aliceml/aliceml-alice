//
// Authors:
//   Thorsten Brunklaus <brunklaus@ps.uni-sb.de>
//   Leif Kornstaedt <kornstae@ps.uni-sb.de>
//
// Copyright:
//   Thorsten Brunklaus, 2002
//   Leif Kornstaedt, 2002
//
// Last Change:
//   $Date$ by $Author$
//   $Revision$
//

#ifndef __GENERIC__BACKTRACE_HH__
#define __GENERIC__BACKTRACE_HH__

#if defined(INTERFACE)
#pragma interface "emulator/Backtrace.hh"
#endif

#include "adt/Queue.hh"
#include "emulator/Interpreter.hh"
#include "emulator/StackFrame.hh"

class Backtrace : private Queue {
public:
  using Queue::ToWord;
  using Queue::Enqueue;
  // Backtrace Accessors
  void Dump() {
    while (!IsEmpty()) {
      word frame = Dequeue();
      Interpreter *interpreter = StackFrame::FromWord(frame)->GetInterpreter();
      interpreter->DumpFrame(frame);
    }
  }
  // Backtrace Constuctor
  static Backtrace *New(word frame) {
    Queue *trace = Queue::New(256);
    trace->Enqueue(frame);
    return static_cast<Backtrace *>(trace);
  }
  // Backtrace Untagging
  static Backtrace *FromWordDirect(word x) {
    Queue *q = Queue::FromWordDirect(x);
    return static_cast<Backtrace *>(q);
  }
};

#endif
