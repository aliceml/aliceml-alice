//
// Author:
//   Leif Kornstaedt <kornstae@ps.uni-sb.de>
//
// Copyright:
//   Leif Kornstaedt, 2002
//
// Last Change:
//   $Date$ by $Author$
//   $Revision$
//

#ifndef __JAVA__TABLE_HH__
#define __JAVA__TABLE_HH__

#if defined(INTERFACE)
#pragma interface "java/Table.hh"
#endif

#include "store/Store.hh"

class DllExport Table: private Block {
protected:
  enum {
    SIZE_POS, // int
    BASE_SIZE
    // ... elements
  };
public:
  using Block::ToWord;

  static Table *New(u_int length) {
    Block *b = Store::AllocBlock(JavaLabel::Table, BASE_SIZE + length);
    b->InitArg(SIZE_POS, Store::IntToWord(length));
    for (u_int i = length; i--; ) b->InitArg(BASE_SIZE + i, null);
    return static_cast<Table *>(b);
  }
  static Table *FromWord(word x) {
    Block *b = Store::WordToBlock(x);
    Assert(b == INVALID_POINTER || b->GetLabel() == JavaLabel::Table);
    return static_cast<Table *>(b);
  }
  static Table *FromWordDirect(word x) {
    Block *b = Store::DirectWordToBlock(x);
    Assert(b->GetLabel() == JavaLabel::Table);
    return static_cast<Table *>(b);
  }

  u_int GetCount() {
    return Store::DirectWordToInt(GetArg(SIZE_POS));
  }
  void Init(u_int index, word value) {
    Assert(index < GetCount());
    InitArg(BASE_SIZE + index, value);
  }
  void Assign(u_int index, word value) {
    Assert(index < GetCount());
    ReplaceArg(BASE_SIZE + index, value);
  }
  word Get(u_int index) {
    Assert(index < GetCount());
    return GetArg(BASE_SIZE + index);
  }
};

#endif
