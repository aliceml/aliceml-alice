/*
 * $Date$
 * $Revision$
 * $Author$
 */

package de.uni_sb.ps.dml.runtime;

import java.rmi.RemoteException;

public interface DMLRemoteValue extends java.rmi.Remote, DMLValue {
    public DMLValue getValue() throws RemoteException;
    public DMLValue request() throws RemoteException;
    public DMLValue apply(DMLValue val) throws RemoteException;
    public DMLValue raise() throws RemoteException;
}
