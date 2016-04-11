# configure options
#
# Some can be overriden on rpmbuild commandline with:
# rpmbuild --define 'variable value'
#   (use any value, ie 1 for flag "with_XXXX" definitions)
#
# E.g. rpmbuild --define 'release_rev 02' may be useful if building
# rpms again and again on the same day, so the newer rpms can be installed.
# bumping the number each time.

####################### Quagga configure options #########################
# with-feature options
%{!?with_snmp:			%global with_snmp		0 }
%{!?with_vtysh:			%global	with_vtysh		1 }
%{!?with_tcp_zebra:		%global	with_tcp_zebra	0 }
%{!?with_zebra:			%global	with_zebra		0 }
%{!?with_isisd:			%global	with_isisd		0 }
%{!?with_pimd:			%global	with_pimd		0 }
%{!?with_ripd:			%global	with_ripd		0 }
%{!?with_ripngd:		%global	with_ripngd		0 }
%{!?with_ospfd:			%global	with_ospfd		0 }
%{!?with_ospf6d:		%global	with_ospf6d		0 }
%{!?with_shared:		%global	with_shared		1 }
%{!?with_multipath:		%global	with_multipath	64 }
%{!?quagga_user:		%global	quagga_user		quagga }
%{!?vty_group:			%global	vty_group		quaggavt }
%{!?with_fpm:			%global	with_fpm 		0 }
%{!?with_doc:			%global	with_doc		0 }

# path defines
%define		_sysconfdir	/etc/quagga
%define		zeb_src		%{_builddir}/%{name}-%{quaggaversion}
%if %{with_doc}
%define		zeb_docs	%{zeb_src}/doc
%endif

# defines for configure
%define		_localstatedir	/var/run/quagga

%define		opnfv_quagga_dir	/usr/lib/quagga

############################################################################

#### Version String tweak
# Remove invalid characters form version string and replace with _
%{expand: %%define rpmversion %(echo '%_VERSION_%' | tr [:blank:]- _ )}
%define         quaggaversion   %_VERSION_%-%_RELEASE_%

#### Check version of texi2html 
# Old versions don't support "--number-footnotes" option.
%{expand: %%global texi2htmlversion %(rpm -q --qf '%%{VERSION}' texi2html | cut -d. -f1 )}

#### Check for systemd or init.d (upstart)
# Check for init.d (upstart) as used in CentOS 6 or systemd (ie CentOS 7)
##%{expand: %%global initsystem %(if [[ `/sbin/init --version 2> /dev/null` =~ upstart ]]; then echo upstart; elif [[ `systemctl` =~ -\.mount ]]; then echo systemd; fi)}
%{expand: %%global initsystem %(if [[ `/sbin/init --version 2> /dev/null` =~ upstart ]]; then echo upstart; elif [[ -f /etc/SuSE-release ]]; then echo upstart; elif [[ `systemctl` =~ -\.mount ]]; then echo systemd; fi)}
#

# if FPM is enabled, then enable tcp_zebra as well
#
%if %{with_fpm}
	%global	with_tcp_zebra	1
%endif

# if TCP zebra enabled, then we need generic zebra as well
#
%if %{with_tcp_zebra}
	%global	with_zebra	1
%endif

# misc internal defines
%{!?quagga_uid:		%define     quagga_uid  92 }
%{!?quagga_gid:		%define     quagga_gid  92 }
%{!?vty_gid:		%define		vty_gid		85 }

%define		daemon_list	zebra ripd ospfd bgpd

%define		daemonv6_list	ripngd ospf6d

%if %{with_isisd}
%define		daemon_isisd	isisd
%else
%define		daemon_isisd	""
%endif

%if %{with_pimd}
%define         daemon_pimd	pimd
%else
%define		daemon_pimd	""
%endif

%define		all_daemons	%{daemon_list} %{daemonv6_list} %{daemon_isisd} %{daemon_pimd}

# allow build dir to be kept
%{!?keep_build:		%global		keep_build	0 }

#release sub-revision (the two digits after the CONFDATE)
%{!?release_rev:	%define		release_rev	01 }

Summary: Routing daemon
Name:			opnfv-quagga
Version:		%{rpmversion}
Release:		%_RELEASE_%%{?dist}
License:		GPLv2+
Group:			System Environment/Daemons
Source0:		%{name}_%{quaggaversion}.orig.tar.gz
Source1:		opnfv-quagga.service
Source2:		opnfv-quagga.init
Source3:		qthriftd.conf
Source4:		opnfv-quagga.sh
Source5:		opnfv-quagga.init-suse
URL:			%_SOURCEURL_%
Requires:		ncurses, python-ply, thriftpy >= 0.3.2, libcapnp-0_5-99, python-pyzmq
Requires(pre):	/sbin/install-info
Requires(preun): /sbin/install-info
Requires(post):	/sbin/install-info
BuildRequires:	autoconf patch libcap-devel groff
%if %{with_doc}
BuildRequires:	texi2html texinfo 
%endif
%if %{with_snmp}
BuildRequires:	net-snmp-devel
Requires:		net-snmp
%endif
%if %{with_vtysh}
BuildRequires:	readline readline-devel ncurses ncurses-devel
Requires:		ncurses
%endif
%if %{?suse_version}
PreReq:         %fillup_prereq
PreReq:         %insserv_prereq
PreReq:         %install_info_prereq
%else
%if "%{initsystem}" == "systemd"
BuildRequires:		systemd
Requires(post):		systemd
Requires(preun):	systemd
Requires(postun):	systemd
%else
# Initscripts > 5.60 is required for IPv6 support
Requires(pre):		initscripts >= 5.60
%endif
%endif
Provides:			routingdaemon = %{version}-%{release}
BuildRoot:			%{_tmppath}/%{name}-%{version}-root
Obsoletes:			bird gated mrt zebra quagga-sysvinit quagga

%description
Quagga is a free software that manages TCP/IP based routing
protocol. It takes multi-server and multi-thread approach to resolve
the current complexity of the Internet.

Quagga supports BGP4, OSPFv2, OSPFv3, ISIS, RIP, RIPng and PIM.

Quagga is intended to be used as a Route Server and a Route Reflector. It is
not a toolkit, it provides full routing power under a new architecture.
Quagga by design has a process for each protocol.

Quagga is a fork of GNU Zebra.

%package contrib
Summary: contrib tools for opnfv-quagga
Group: System Environment/Daemons

%description contrib
Contributed/3rd party tools which may be of use with opnfv-quagga.

%package devel
Summary: Header and object files for opnfv-quagga development
Group: System Environment/Daemons
Requires: %{name} = %{version}-%{release}

%description devel
The opnfv-quagga-devel package contains the header and object files neccessary for
developing OSPF-API and opnfv-quagga applications.

%prep
%setup  -q -n quaggasrc-rpm

%build

# For standard gcc verbosity, uncomment these lines:
#CFLAGS="%{optflags} -Wall -Wsign-compare -Wpointer-arith"
#CFLAGS="${CFLAGS} -Wbad-function-cast -Wwrite-strings"

# For ultra gcc verbosity, uncomment these lines also:
#CFLAGS="${CFLAGS} -W -Wcast-qual -Wstrict-prototypes"
#CFLAGS="${CFLAGS} -Wmissing-declarations -Wmissing-noreturn"
#CFLAGS="${CFLAGS} -Wmissing-format-attribute -Wunreachable-code"
#CFLAGS="${CFLAGS} -Wpacked -Wpadded"

%configure \
    --sysconfdir=%{_sysconfdir} \
    --libdir=%{_libdir} \
	--sbindir=%{opnfv_quagga_dir} \
    --libexecdir=%{_libexecdir} \
    --localstatedir=%{_localstatedir} \
	--disable-werror \
%if !%{with_shared}
	--disable-shared \
%endif
%if !%{with_pimd}
	--disable-pimd \
%endif
%if %{with_snmp}
	--enable-snmp \
%endif
%if %{with_multipath}
	--enable-multipath=%{with_multipath} \
%endif
%if !%{with_zebra}
	--disable-zebra \
%endif
%if %{with_tcp_zebra}
	--enable-tcp-zebra \
%endif
%if %{with_vtysh}
	--enable-vtysh \
%else
	--disable-vtysh \
%endif
	--enable-ospfclient=no\
	--enable-ospfapi=no \
	--enable-irdp=no \
	--enable-rtadv=no \
%if !%{with_ripd}
	--disable-ripd \
%endif
%if !%{with_ripngd}
	--disable-ripngd \
%endif
%if !%{with_ospfd}
	--disable-ospfd \
%endif
%if !%{with_ospf6d}
	--disable-ospf6d \
%endif
%if %{with_isisd}
	--enable-isisd \
%else
	--disable-isisd \
%endif
%if 0%{?quagga_user:1}
	--enable-user=%quagga_user \
	--enable-group=%quagga_user \
%endif
%if 0%{?vty_group:1}
	--enable-vty-group=%vty_group \
%endif
%if %{with_fpm}
	--enable-fpm \
%else
	--disable-fpm \
%endif
	--disable-watchquagga \
	--with-zeromq \
	--enable-gcc-rdynamic

	
make %{?_smp_mflags} MAKEINFO="makeinfo --no-split"

%if %{with_doc}
pushd doc
%if %{texi2htmlversion} < 5
texi2html --number-sections quagga.texi
%else
texi2html --number-footnotes  --number-sections quagga.texi
%endif
popd
%endif

%install
mkdir -p %{buildroot}/etc/quagga \
         %{buildroot}/var/log/quagga %{buildroot}%{_infodir}
make DESTDIR=%{buildroot} INSTALL="install -p" CP="cp -p" install
# install Quagga Thrift Interface
mkdir -p %{buildroot}/usr/lib/quagga/qthrift
cp -a qthrift/* %{buildroot}/usr/lib/quagga/qthrift/
cp -a %{SOURCE4} %{buildroot}/usr/lib/quagga/qthrift/
chmod 755 %{buildroot}/usr/lib/quagga/qthrift/*.py
chmod 755 %{buildroot}/usr/lib/quagga/qthrift/*.sh

# Remove this file, as it is uninstalled and causes errors when building on RH9
rm -rf %{buildroot}/usr/share/info/dir

# install /etc sources
%if "%{initsystem}" == "systemd"
	mkdir -p %{buildroot}%{_unitdir}
	install %{SOURCE1} \
		%{buildroot}%{_unitdir}/opnfv-quagga.service
%else
	%if %{?suse_version}
		mkdir -p %{buildroot}/etc/init.d
		install %{SOURCE5} \
                	%{buildroot}/etc/init.d/opnfv-quagga
	%else
		mkdir -p %{buildroot}/etc/rc.d/init.d
		install %{SOURCE2} \
			%{buildroot}/etc/rc.d/init.d/opnfv-quagga
	%endif
%endif

install %{SOURCE3} %{buildroot}%{_sysconfdir}/qthriftd.conf

%pre
# add vty_group
%if 0%{?vty_group:1}
if getent group %vty_group > /dev/null ; then : ; else \
 /usr/sbin/groupadd -r -g %vty_gid %vty_group > /dev/null || : ; fi
%endif

# add quagga user and group
%if 0%{?quagga_user:1}
# Ensure that quagga_gid gets correctly allocated
if getent group %quagga_user >/dev/null; then : ; else \
 /usr/sbin/groupadd -g %quagga_gid %quagga_user > /dev/null || : ; \
fi
if getent passwd %quagga_user >/dev/null ; then : ; else \
 /usr/sbin/useradd  -u %quagga_uid -g %quagga_gid \
  -M -r -s /sbin/nologin -c "Quagga routing suite" \
  -d %_localstatedir %quagga_user 2> /dev/null || : ; \
fi
%endif

%post
# zebra_spec_add_service <service name> <port/proto> <comment>
# e.g. zebra_spec_add_service zebrasrv 2600/tcp "zebra service"

zebra_spec_add_service ()
{
  # Add port /etc/services entry if it isn't already there 
  if [ -f /etc/services ] && \
      ! %__sed -e 's/#.*$//' /etc/services | %__grep -wq $1 ; then
    echo "$1		$2			# $3"  >> /etc/services
  fi
}

%if %{with_zebra}
zebra_spec_add_service zebrasrv 2600/tcp "zebra service"
zebra_spec_add_service zebra    2601/tcp "zebra vty"
%endif
%if %{with_ripd}
zebra_spec_add_service ripd     2602/tcp "RIPd vty"
%endif
%if %{with_ripngd}
zebra_spec_add_service ripngd   2603/tcp "RIPngd vty"
%endif
%if %{with_ospfd}
zebra_spec_add_service ospfd    2604/tcp "OSPFd vty"
%endif
%if %{with_ospf6d}
zebra_spec_add_service ospf6d   2606/tcp "OSPF6d vty"
%endif
zebra_spec_add_service bgpd     2605/tcp "BGPd vty"
%if %{with_isisd}
zebra_spec_add_service isisd    2608/tcp "ISISd vty"
%endif
%if %{with_pimd}
zebra_spec_add_service pimd     2611/tcp "PIMd vty"
%endif

%if %{?suse_version}
%install_info --info-dir=%{_infodir} %{_infodir}/%{name}.info.gz
%else
/sbin/install-info %{_infodir}/quagga.info.gz %{_infodir}/dir
%endif

%if 0%{?quagga_user:1}
	chown %quagga_user:%quagga_user %{_sysconfdir}/qthriftd.conf
%endif

%if %{?suse_version}
	%fillup_and_insserv 
	/sbin/chkconfig opnfv-quagga on
	/etc/init.d/opnfv-quagga start
%else
	%if "%{initsystem}" == "systemd"
		%systemd_post opnfv-quagga.service
		systemctl enable opnfv-quagga
		systemctl start opnfv-quagga
	%else
		/sbin/chkconfig --add opnfv-quagga
		/sbin/chkconfig opnfv-quagga on
		/etc/init.d/opnfv-quagga start
	%endif
%endif

%postun
%if %{?suse_version}
	%install_info_delete --info-dir=%{_infodir} %{_infodir}/%{name}.info.gz
	%restart_on_update opnfv-quagga
	%insserv_cleanup
%else
	if [ "$1" -ge 1 ]; then
		%if "%{initsystem}" == "systemd"
			##
			## Systemd Version
			##
			# Stop all daemons.
			%systemd_postun opnfv-quagga.service
			#
			# Start all daemons.
			%systemd_post opnfv-quagga.service
		%else
			##
			## init.d Version
			##
			# Stop all daemons.
			/etc/rc.d/init.d/opnfv-quagga stop >/dev/null 2>&1
			#
			# Start all daemons.
			/etc/rc.d/init.d/opnfv-quagga start >/dev/null 2>&1
		%endif
	fi
%endif

%preun
%if %{?suse_version}
	%stop_on_removal opnfv-quagga
%else
	%if "%{initsystem}" == "systemd"
		##
		## Systemd Version
		##
		if [ "$1" = "0" ]; then
			%systemd_preun opnfv-quagga.service
		fi
	%else
		##
		## init.d Version
		##
		if [ "$1" = "0" ]; then
			/etc/rc.d/init.d/opnfv-quagga stop  >/dev/null 2>&1
			/sbin/chkconfig --del opnfv-quagga
		fi
	%endif
	/sbin/install-info --delete %{_infodir}/quagga.info.gz %{_infodir}/dir
%endif

%clean
%if !0%{?keep_build:1}
rm -rf %{buildroot}
%endif

%files
%defattr(-,root,root)
%if %{with_doc}
%doc */*.sample* AUTHORS COPYING
%doc doc/quagga.html
%doc doc/mpls
%endif
%doc ChangeLog INSTALL NEWS README REPORTING-BUGS SERVICES TODO
%if 0%{?quagga_user:1}
%dir %attr(751,%quagga_user,%quagga_user) %{_sysconfdir}
%dir %attr(750,%quagga_user,%quagga_user) /var/log/quagga 
###%dir %attr(751,%quagga_user,%quagga_user) /var/run/quagga
%else
%dir %attr(750,root,root) %{_sysconfdir}
%dir %attr(750,root,root) /var/log/quagga
###%dir %attr(750,root,root) /var/run/quagga
%endif
%if 0%{?vty_group:1}
%attr(750,%quagga_user,%vty_group) %{_sysconfdir}/vtysh.conf.sample
%endif
%{_infodir}/quagga.info.gz
%{_mandir}/man*/*
%if %{with_zebra}
%{opnfv_quagga_dir}/zebra
%endif
%if %{with_ospfd}
%{opnfv_quagga_dir}/ospfd
%endif
%if %{with_ripd}
%{opnfv_quagga_dir}/ripd
%endif
%{opnfv_quagga_dir}/bgpd
%if %{with_ripngd}
%{opnfv_quagga_dir}/ripngd
%endif
%if %{with_ospf6d}
%{opnfv_quagga_dir}/ospf6d
%endif
%{opnfv_quagga_dir}/qthrift/*
%if %{with_pimd}
%{opnfv_quagga_dir}/pimd
%endif
%if %{with_isisd}
%{opnfv_quagga_dir}/isisd
%endif
%if %{with_shared}
%attr(755,root,root) %{_libdir}/lib*.so
%attr(755,root,root) %{_libdir}/lib*.so.*
%endif
%if %{with_vtysh}
%{_bindir}/*
%endif
%config /etc/quagga/[!v]*
%if "%{initsystem}" == "systemd"
%config %{_unitdir}/opnfv-quagga.service
%else
%if %{?suse_version}
%config /etc/init.d/opnfv-quagga
%else
%config /etc/rc.d/init.d/opnfv-quagga
%endif
%endif

%files contrib
%defattr(-,root,root)
%doc tools

%files devel
%defattr(-,root,root)
%{_libdir}/*.a
%{_libdir}/*.la
%dir %attr(755,root,root) %{_includedir}/%{name}
%{_includedir}/%name/*.h
%if %{with_ospfd}
%dir %attr(755,root,root) %{_includedir}/%{name}/ospfd
%{_includedir}/%name/ospfd/*.h
%endif

%changelog
* %_DATE_% %_USER_% %_EMAIL_% - %{version}-%{release}
  * OPNFV Build of Quagga with Thrift Interface by %_USER_%
  * Built based on Quagga Git Rev %_QUAGGAREV_% from
    %_QUAGGAGIT_%
  * Added Thrift Interface Git Rev %_QTHRIFTREV_% from
    %_QTHRIFTGIT_%

* Mon Apr  4 2016 Martin Winter <mwinter@opensourcerouting.org> - %{version}
- Adopted for OPNFV-Quagga:
	- renamed RPM to opnfv-quagga
    - removed watchquagga option
        
* Thu Feb 11 2016 Paul Jakma <paul@jakma.org> - %{version}
- remove with_ipv6 conditionals, always build v6
- Fix UTF-8 char in spec changelog
- remove quagga.pam.stack, long deprecated.

* Thu Oct 22 2015 Martin Winter <mwinter@opensourcerouting.org>
- Cleanup configure: remove --enable-ipv6 (default now), --enable-nssa,
    --enable-netlink
- Remove support for old fedora 4/5
- Fix for package nameing
- Fix Weekdays of previous changelogs (bogus dates)
- Add conditional logic to only build tex footnotes with supported texi2html 
- Added pimd to files section and fix double listing of /var/lib*/quagga
- Numerous fixes to unify upstart/systemd startup into same spec file
- Only allow use of watchquagga for non-systemd systems. no need with systemd

* Fri Sep  4 2015 Paul Jakma <paul@jakma.org>
- buildreq updates
- add a default define for with_pimd

* Mon Sep 12 2005 Paul Jakma <paul@dishone.st>
- Steal some changes from Fedora spec file:
- Add with_rtadv variable
- Test for groups/users with getent before group/user adding
- Readline need not be an explicit prerequisite
- install-info delete should be postun, not preun

* Wed Jan 12 2005 Andrew J. Schorr <ajschorr@alumni.princeton.edu>
- on package upgrade, implement careful, phased restart logic
- use gcc -rdynamic flag when linking for better backtraces

* Wed Dec 22 2004 Andrew J. Schorr <ajschorr@alumni.princeton.edu>
- daemonv6_list should contain only IPv6 daemons

* Wed Dec 22 2004 Andrew J. Schorr <ajschorr@alumni.princeton.edu>
- watchquagga added
- on upgrade, all daemons should be condrestart'ed
- on removal, all daemons should be stopped

* Mon Nov 08 2004 Paul Jakma <paul@dishone.st>
- Use makeinfo --html to generate quagga.html

* Sun Nov 07 2004 Paul Jakma <paul@dishone.st>
- Fix with_ipv6 set to 0 build

* Sat Oct 23 2004 Paul Jakma <paul@dishone.st>
- Update to 0.97.2

* Sat Oct 23 2004 Andrew J. Schorr <aschorr@telemetry-investments.com>
- Make directories be owned by the packages concerned
- Update logrotate scripts to use correct path to killall and use pid files

* Fri Oct 08 2004 Paul Jakma <paul@dishone.st>
- Update to 0.97.0

* Wed Sep 15 2004 Paul Jakma <paul@dishone.st>
- build snmp support by default
- build irdp support
- build with shared libs
- devel subpackage for archives and headers

* Thu Jan 08 2004 Paul Jakma <paul@dishone.st>
- updated sysconfig files to specify local dir
- added ospf_dump.c crash quick fix patch
- added ospfd persistent interface configuration patch

* Tue Dec 30 2003 Paul Jakma <paul@dishone.st>
- sync to CVS
- integrate RH sysconfig patch to specify daemon options (RH)
- default to have vty listen only to 127.1 (RH)
- add user with fixed UID/GID (RH)
- create user with shell /sbin/nologin rather than /bin/false (RH)
- stop daemons on uninstall (RH)
- delete info file on preun, not postun to avoid deletion on upgrade. (RH)
- isisd added
- cleanup tasks carried out for every daemon

* Sun Nov 2 2003 Paul Jakma <paul@dishone.st>
- Fix -devel package to include all files
- Sync to 0.96.4

* Tue Aug 12 2003 Paul Jakma <paul@dishone.st>
- Renamed to Quagga
- Sync to Quagga release 0.96

* Thu Mar 20 2003 Paul Jakma <paul@dishone.st>
- zebra privileges support

* Tue Mar 18 2003 Paul Jakma <paul@dishone.st>
- Fix mem leak in 'show thread cpu'
- Ralph Keller's OSPF-API
- Amir: Fix configure.ac for net-snmp

* Sat Mar 1 2003 Paul Jakma <paul@dishone.st>
- ospfd IOS prefix to interface matching for 'network' statement
- temporary fix for PtP and IPv6
- sync to zebra.org CVS

* Mon Jan 20 2003 Paul Jakma <paul@dishone.st>
- update to latest cvs
- Yon's "show thread cpu" patch - 17217
- walk up tree - 17218
- ospfd NSSA fixes - 16681
- ospfd nsm fixes - 16824
- ospfd OLSA fixes and new feature - 16823 
- KAME and ifindex fixes - 16525
- spec file changes to allow redhat files to be in tree

* Sat Dec 28 2002 Alexander Hoogerhuis <alexh@ihatent.com>
- Added conditionals for building with(out) IPv6, vtysh, RIP, BGP
- Fixed up some build requirements (patch)
- Added conditional build requirements for vtysh / snmp
- Added conditional to files for _bindir depending on vtysh

* Mon Nov 11 2002 Paul Jakma <paulj@alphyra.ie>
- update to latest CVS
- add Greg Troxel's md5 buffer copy/dup fix
- add RIPv1 fix
- add Frank's multicast flag fix

* Wed Oct 09 2002 Paul Jakma <paulj@alphyra.ie>
- update to latest CVS
- timestamped crypt_seqnum patch
- oi->on_write_q fix

* Mon Sep 30 2002 Paul Jakma <paulj@alphyra.ie>
- update to latest CVS
- add vtysh 'write-config (integrated|daemon)' patch
- always 'make rebuild' in vtysh/ to catch new commands

* Fri Sep 13 2002 Paul Jakma <paulj@alphyra.ie>
- update to 0.93b

* Wed Sep 11 2002 Paul Jakma <paulj@alphyra.ie>
- update to latest CVS
- add "/sbin/ip route flush proto zebra" to zebra RH init on startup

* Sat Aug 24 2002 Paul Jakma <paulj@alphyra.ie>
- update to current CVS
- add OSPF point to multipoint patch
- add OSPF bugfixes
- add BGP hash optimisation patch

* Fri Jun 14 2002 Paul Jakma <paulj@alphyra.ie>
- update to 0.93-pre1 / CVS
- add link state detection support
- add generic PtP and RFC3021 support
- various bug fixes

* Thu Aug 09 2001 Elliot Lee <sopwith@redhat.com> 0.91a-6
- Fix bug #51336

* Wed Aug  1 2001 Trond Eivind Glomsrød <teg@redhat.com> 0.91a-5
- Use generic initscript strings instead of initscript specific
  ( "Starting foo: " -> "Starting $prog:" )

* Fri Jul 27 2001 Elliot Lee <sopwith@redhat.com> 0.91a-4
- Bump the release when rebuilding into the dist.

* Tue Feb  6 2001 Tim Powers <timp@redhat.com>
- built for Powertools

* Sun Feb  4 2001 Pekka Savola <pekkas@netcore.fi> 
- Hacked up from PLD Linux 0.90-1, Mandrake 0.90-1mdk and one from zebra.org.
- Update to 0.91a
- Very heavy modifications to init.d/*, .spec, pam, i18n, logrotate, etc.
- Should be quite Red Hat'isque now.
