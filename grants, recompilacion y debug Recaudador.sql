BEGIN
DBMS_UTILITY.COMPILE_SCHEMA('RECAUDADOR');
END;
/
 
 
ALTER USER DEV_DN0018 QUOTA UNLIMITED ON REC_CAJAS;
ALTER USER DEV_DN0018 QUOTA UNLIMITED ON REC_CAJAS_IND;
ALTER USER DEV_DN0018 QUOTA UNLIMITED ON REC_CARGAS;
ALTER USER DEV_DN0018 QUOTA UNLIMITED ON REC_CARGAS_IND;
ALTER USER DEV_DN0018 QUOTA UNLIMITED ON REC_CATALOGOS;
ALTER USER DEV_DN0018 QUOTA UNLIMITED ON REC_CATALOGOS_IND;
ALTER USER DEV_DN0018 QUOTA UNLIMITED ON REC_PADRON;
ALTER USER DEV_DN0018 QUOTA UNLIMITED ON REC_PADRON_IND;

BEGIN
DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE
(
host => '10.0.*.*',
lower_port => null,
upper_port => null,
ace => xs$ace_type(privilege_list => xs$name_list('jdwp'),
principal_name => 'DEV_DN0018',
principal_type => xs_acl.ptype_db)
);
END;
/

grant execute on DBMS_DEBUG_JDWP to TRECA;
grant debug any procedure to TRECA;
grant debug connect session to TRECA;

begin
DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE
      (HOST=>'*',
       ace=> SYS.XS$ACE_TYPE(privilege_list=>sys.XS$NAME_LIST('JDWP') ,
                          principal_name=>'TRECA',
                          principal_type=>sys.XS_ACL.PTYPE_DB) );
end;
/

BEGIN
DBMS_UTILITY.COMPILE_SCHEMA('DEV_DN0018');
END;
/