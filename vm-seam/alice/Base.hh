//
// Author:
//   Leif Kornstaedt <kornstae@ps.uni-sb.de>
//
// Copyright:
//   Leif Kornstaedt, 2003
//
// Last Change:
//   $Date$ by $Author$
//   $Revision$
//

#ifndef __ALICE__BASE_HH__
#define __ALICE__BASE_HH__

#include "Seam.hh"

#if defined(__MINGW32__) || defined(_MSC_VER)
# if defined(ALICE_FOREIGN)
#  define AliceDll __declspec(dllimport)
# else
#  define AliceDll __declspec(dllexport)
# endif
#else
# define AliceDll
#endif

#if HAVE_LIGHTNING
#define ALICE_USE_JITTER 1
#endif

#endif
