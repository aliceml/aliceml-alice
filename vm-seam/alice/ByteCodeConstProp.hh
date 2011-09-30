//
// Author:
//   Christian Mueller <cmueller@ps.uni-sb.de>
//
// Copyright:
//   Christian Mueller, 2005
//
// Last Change:
//   $Date$ by $Author$
//   $Revision$
//

#ifndef __ALICE_BYTECODE_CONST_PROP_HH__
#define __ALICE_BYTECODE_CONST_PROP_HH__

#if defined(INTERFACE)
#pragma interface "alice/ByteCodeConstProp.hh"
#endif

#include "alice/Data.hh"
#include "alice/ByteCodeInliner.hh"


/**
 * Constant Propagation information for a function.
 */
class ConstPropInfo : private Tuple {
private:
  enum { TAG_TEST_INFO_POS, INLINE_MAP_POS, SIZE };
public:
  using Tuple::ToWord;
  
  static ConstPropInfo *FromWord(word info) {
    return static_cast<ConstPropInfo *>(Tuple::FromWord(info));
  }
  
  static ConstPropInfo *FromWordDirect(word info) {
    return static_cast<ConstPropInfo *>(Tuple::FromWordDirect(info));
  }
  
  static ConstPropInfo *New() {
    Tuple *t = Tuple::New(SIZE);
    t->Init(TAG_TEST_INFO_POS, Map::New(8)->ToWord());
    t->Init(INLINE_MAP_POS, Map::New(8)->ToWord());
    return reinterpret_cast<ConstPropInfo*>(t);
  }
  
  /**
   * @return A map from (Compact)TagTest instr to (idDef vector * instr)
   *         continuation for each (Compact)TagTest whose branch can be
   *         determined statically.
   */
  Map *GetTagTestInfo() {
    return Map::FromWordDirect(Sel(TAG_TEST_INFO_POS));
  }
  
  /**
   * @return A map from each inlined AppVar instr to the ConstPropInfo
   *         for the inlined function
   */
  Map *GetInlineMap() {
    return Map::FromWordDirect(Sel(TAG_TEST_INFO_POS));
  }
};


class ByteCodeConstProp {
public:
  static ConstPropInfo *Analyse(TagVal* abstractCode, InlineInfo *inlineInfo);
};

#endif
