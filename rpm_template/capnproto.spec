#
# spec file for package capnproto
#
# Copyright (c) 2015 SUSE LINUX GmbH, Nuernberg, Germany.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugs.opensuse.org/
#

Name:           capnproto
Version:	0.5.99
Release:	1
License:	MIT
Summary:	Cap'n Proto - Insanely Fast Data Serialization Format
Url:	https://capnproto.org
Group:	System/Libraries
Source:	https://capnproto.org/capnproto_%{version}.orig.tar.gz
BuildRequires:	pkgconfig
Requires:	libcapnp-0_5-99 = %{version}
BuildRoot:      %{_tmppath}/%{name}-%{version}-build

%description
Cap'n Proto is an insanely fast data interchange format and capability-based
RPC system.  Think JSON, except binary.  Or think of Google's Protocol Buffers
(http://protobuf.googlecode.com), except faster.  In fact, in benchmarks,
Cap'n Proto is INFINITY TIMES faster than Protocol Buffers.

%package -n libcapnp-0_5-99
Summary:	Cap'n Proto C++ library
Group:	System/Libraries

%description -n libcapnp-0_5-99
Cap'n Proto is an insanely fast data interchange format and capability-based
RPC system.  Think JSON, except binary.  Or think of Google's Protocol Buffers
(http://protobuf.googlecode.com), except faster.  In fact, in benchmarks,
Cap'n Proto is INFINITY TIMES faster than Protocol Buffers.

This package provides runtime libraries for capnproto.

%package -n libcapnp-devel
Summary:	Development headers for Cap'n Proto C++ Library
Group:	Development/Libraries/C and C++
Requires:	libcapnp-0_5-99 = %{version}

%description -n libcapnp-devel
Cap'n Proto is an insanely fast data interchange format and capability-based
RPC system.  Think JSON, except binary.  Or think of Google's Protocol Buffers
(http://protobuf.googlecode.com), except faster.  In fact, in benchmarks,
Cap'n Proto is INFINITY TIMES faster than Protocol Buffers.

This package provides development headers for capnproto.

%prep
%setup -q -n c++

%build
%configure
make %{?_smp_mflags}

%install
make install DESTDIR=%{buildroot} %{?_smp_mflags}
find %{buildroot}%{_libdir} -name "*.a" -delete
find %{buildroot}%{_libdir} -name "*.la" -delete

%post -n libcapnp-0_5-99 -p /sbin/ldconfig

%postun -n libcapnp-0_5-99 -p /sbin/ldconfig

%files
%defattr(-,root,root)
%doc README.txt LICENSE.txt
%{_bindir}/capnp
%{_bindir}/capnpc
%{_bindir}/capnpc-c++
%{_bindir}/capnpc-capnp

%files -n libcapnp-0_5-99
%defattr(-,root,root)
%{_libdir}/libcapnp-0.5.99.so
%{_libdir}/libcapnp-rpc-0.5.99.so
%{_libdir}/libcapnpc-0.5.99.so
%{_libdir}/libkj-0.5.99.so
%{_libdir}/libkj-async-0.5.99.so
%{_libdir}/libkj-test-0.5.99.so
%{_libdir}/libkj-test.so

%files -n libcapnp-devel
%defattr(-,root,root)
%{_includedir}/capnp
%{_includedir}/kj
%{_libdir}/cmake/CapnProto
%{_libdir}/libcapnp-rpc.so
%{_libdir}/libcapnp.so
%{_libdir}/libcapnpc.so
%{_libdir}/libkj-async.so
%{_libdir}/libkj.so
%{_libdir}/pkgconfig/capnp.pc
%{_libdir}/pkgconfig/capnp-rpc.pc
%changelog
* Mon Apr  4 2016 mwinter@netdef.org
- update version 0.5.99-1
* Sun Mar 15 2015 i@marguerite.su
- update version 0.5.1.2
* Wed Feb 18 2015 i@marguerite.su
- initial version 0.5.1
