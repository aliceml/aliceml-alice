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

#include <unistd.h>
#include <netdb.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <arpa/inet.h>

#include "emulator/Authoring.hh"

static char *ExportCString(String *s) {
  u_int sLen = s->GetSize();
  String *e  = String::New(sLen + 1);
  u_char *eb = e->GetValue();
  std::memcpy(eb, s->GetValue(), sLen);
  eb[sLen] = '\0';
  return reinterpret_cast<char *>(eb);
}

static int setNonBlocking(int sock, bool flag) {
  unsigned long arg = flag;
#if defined(__MINGW32__) || defined(_MSC_VER)
  return ioctlsocket(sock, FIONBIO, &arg);
#else
  return ioctl(sock, FIONBIO, &arg);
#endif
}

DEFINE1(UnsafeSocket_server) {
  DECLARE_INT(port, x0);

  int sock = socket(PF_INET, SOCK_STREAM, 0);
  if (sock < 0) {
    RAISE(Store::IntToWord(0)); //--** IO.Io
  }

  // bind a name to the socket:
  sockaddr_in addr;
  socklen_t addrLen = sizeof(addr);
  std::memset(&addr, 0, sizeof(addr));
  addr.sin_family = AF_INET;
  addr.sin_addr.s_addr = htonl(INADDR_ANY);
  addr.sin_port = htons(port);
  if (bind(sock, reinterpret_cast<sockaddr *>(&addr), addrLen) < 0) {
    RAISE(Store::IntToWord(0)); //--** IO.Io
  }

  // listen for connections:
  static const u_int backLog = 5;
  int ret = listen(sock, backLog);
  Assert(ret == 0); ret = ret;

  if (getsockname(sock, reinterpret_cast<sockaddr *>(&addr), &addrLen) < 0) {
    RAISE(Store::IntToWord(0)); //--** IO.Io
  }
  Tuple *tuple = Tuple::New(2);
  tuple->Init(0, Store::IntToWord(sock));
  tuple->Init(1, Store::IntToWord(ntohs(addr.sin_port)));
  RETURN(tuple->ToWord());
} END

DEFINE1(UnsafeSocket_accept) {
  DECLARE_INT(sock, x0);

  sockaddr_in addr;
  socklen_t addrLen = sizeof(addr);
  int client = accept(sock, reinterpret_cast<sockaddr *>(&addr), &addrLen);
  if (client < 0) {
    RAISE(Store::IntToWord(0)); //--** IO.Io
  }

  const char *host = inet_ntoa(addr.sin_addr);
  if (!strcmp(host, "127.0.0.1")) {
    // workaround for misconfigured offline hosts:
    host = "localhost";
  } else {
    hostent *entry =
      gethostbyaddr(reinterpret_cast<char *>(&addr.sin_addr),
		    addrLen, AF_INET);
    if (entry)
      host = entry->h_name;
  }

  Tuple *tuple = Tuple::New(3);
  tuple->Init(0, Store::IntToWord(client));
  tuple->Init(1, String::New(host)->ToWord());
  tuple->Init(2, Store::IntToWord(ntohs(addr.sin_port)));
  RETURN(tuple->ToWord());
} END

DEFINE2(UnsafeSocket_client) {
  DECLARE_STRING(host, x0);
  DECLARE_INT(port, x1);

  int sock = socket(PF_INET, SOCK_STREAM, 0);
  if (sock < 0) {
    RAISE(Store::IntToWord(0)); //--** IO.Io
  }

  hostent *entry = gethostbyname(ExportCString(host));
  if (!entry) {
    RAISE(Store::IntToWord(0)); //--** IO.Io
  }
  sockaddr_in addr;
  std::memset(&addr, 0, sizeof(addr));
  addr.sin_family = AF_INET;
  std::memcpy(&addr.sin_addr, entry->h_addr_list[0], sizeof(addr.sin_addr));
  addr.sin_port = htons(port);

  if (connect(sock, reinterpret_cast<sockaddr *>(&addr), sizeof(addr)) < 0) {
    RAISE(Store::IntToWord(0)); //--** IO.Io
  }
  RETURN_INT(sock);
} END

DEFINE1(UnsafeSocket_input1) {
  DECLARE_INT(sock, x0);

  u_char c;
  int n = recv(sock, &c, 1, MSG_PEEK);
  if (n < 0) {
    RAISE(Store::IntToWord(0)); //--** IO.Io
  } else if (n == 0) { // EOF
    RETURN_INT(0); // NONE
  } else {
    Assert(n == 1);
    TagVal *tagVal = TagVal::New(1, 1); // SOME ...
    tagVal->Init(0, Store::IntToWord(c));
    RETURN(tagVal->ToWord());
  }
} END

DEFINE2(UnsafeSocket_inputN) {
  DECLARE_INT(sock, x0);
  DECLARE_INT(count, x1);

  if (count < 0 || static_cast<u_int>(count) > String::maxSize) {
    RAISE(PrimitiveTable::General_Size);
  }
  String *buffer = String::New(count);
  int nread = 0;
  while (nread < count) {
    int n = recv(sock, buffer->GetValue() + nread, count - nread, 0);
    if (n < 0) {
      RAISE(Store::IntToWord(0)); //--** IO.Io
    } else if (n == 0) {
      String *string = String::New(nread);
      std::memcpy(string->GetValue(), buffer->GetValue(), nread);
      RETURN(string->ToWord());
    }
    nread += n;
  }
  RETURN(buffer->ToWord());
} END

DEFINE2(UnsafeSocket_output1) {
  DECLARE_INT(sock, x0);
  DECLARE_INT(i, x1);
  u_char c = i;
  if (send(sock, &c, 1, 0) < 0) {
    RAISE(Store::IntToWord(0)); //--** IO.Io
  }
  RETURN_UNIT;
} END

DEFINE2(UnsafeSocket_output) {
  DECLARE_INT(sock, x0);
  DECLARE_STRING(string, x1);

  u_char *buffer = string->GetValue();
  u_int count = string->GetSize();
  while (count > 0) {
    int n = send(sock, buffer, string->GetSize(), 0);
    if (n < 0) {
      RAISE(Store::IntToWord(0)); //--** IO.Io
    }
    count -= n;
    buffer += n;
  }
  RETURN_UNIT;
} END

DEFINE1(UnsafeSocket_close) {
  DECLARE_INT(sock, x0);

#if defined(__MINGW32__) || defined(_MSC_VER)
  closesocket(sock);
#else
  close(sock);
#endif

  RETURN_UNIT;
} END

word UnsafeSocket() {
  Tuple *t = Tuple::New(8);
  t->Init(0, Primitive::MakeClosure("UnsafeSocket_accept",
				    UnsafeSocket_accept, 1, true));
  t->Init(1, Primitive::MakeClosure("UnsafeSocket_client",
				    UnsafeSocket_client, 2, true));
  t->Init(2, Primitive::MakeClosure("UnsafeSocket_close",
				    UnsafeSocket_close, 1, true));
  t->Init(3, Primitive::MakeClosure("UnsafeSocket_input1",
				    UnsafeSocket_input1, 1, true));
  t->Init(4, Primitive::MakeClosure("UnsafeSocket_inputN",
				    UnsafeSocket_inputN, 2, true));
  t->Init(5, Primitive::MakeClosure("UnsafeSocket_output",
				    UnsafeSocket_output, 2, true));
  t->Init(6, Primitive::MakeClosure("UnsafeSocket_output1",
				    UnsafeSocket_output1, 2, true));
  t->Init(7, Primitive::MakeClosure("UnsafeSocket_server",
				    UnsafeSocket_server, 1, true));
  RETURN_STRUCTURE(t);
}
