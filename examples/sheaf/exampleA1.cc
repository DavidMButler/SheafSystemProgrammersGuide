// $RCSfile: main.t.cc,v $ $Revision: 1.1 $ $Date: 2009/07/31 18:01:41 $

// $Name:  $
//
// Copyright (c) 2008 Limit Point Systems, Inc. 
//

/// @example Example A1: Manual concurrency access control.
/// SheafSystem Programmer's Guide Example A1: Manual concurrency access control. 

#include "sheaves_namespace.h"
#include "std_iostream.h"

using namespace sheaf;

int main( int argc, char* argv[])
{
  cout << "SheafSystemProgrammersGuide ExampleA1:" << endl;

  // Enable concurrency control; must be called
  // before any other library call.

  read_write_monitor::enable_access_control();

  // Create a standard sheaves namespace.

  sheaves_namespace* lns = new sheaves_namespace("Example3A");

  // Write its name to cout.
  // Requires read access to the namespace.
  
  // Be polite, request access.
  // If and threads are enabled and another thread has 
  // read-write access, execution will block until it 
  // releases access. Otherwise, the request will succeed 
  // immediately.

  // Can nest requests as deep as you want, or at least 
  // until the integer depth counter overflows.

  cout << "access request depth " << lns->access_request_depth() << endl;
  lns->get_read_access();
  cout << "access request depth " << lns->access_request_depth() << endl;
  lns->get_read_access();
  cout << "access request depth " << lns->access_request_depth() << endl;

  // Invoke the operation.

  cout << lns->name() << endl;

  // Be proper, release access so this thread
  // or another can get write access.
  // Have to match every request with a release.
 
  cout << "access request depth " << lns->access_request_depth() << endl;
  lns->release_access();
  cout << "access request depth " << lns->access_request_depth() << endl;
  lns->release_access();
  cout << "access request depth " << lns->access_request_depth() << endl;

  // Delete the namespace, requires read-write access.
  // Be polite, request access. If threads are enabled
  // and another thread has either read or read-write 
  // access, execution will block until it releases access. 
  // Otherwise, the request will succeed immediately.
  // This client must not already have read-only access,
  // see precondition for details.

  lns->get_read_write_access(false);
  
  // Invoke the operation.
  
  delete lns;
  
  // Deletion is the only case where the client
  // can not be proper and release access.
  
  // Create another namespace.

  lns = new sheaves_namespace("Example3B");

  // Invoking a function that requires access
  // without first getting access violates the
  // precondition of the function.
  // The following will throw an exception and abort.

  cout << lns->name() << endl;
  
  return 0;
}

  
