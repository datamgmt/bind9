$TTL 1d
$ORIGIN example.com.

@       IN      SOA     ns1 root (
                2019122502      ;serial
                12h             ;refresh
                15m             ;retry
                3w              ;expire
                2h              ;minimum
        )

@       IN      A       192.168.1.81

@       IN      NS      ns1
ns1     IN      A       192.168.1.81

@       IN      MX      10      mail
mail    IN      A       192.168.1.81

www     IN      A       192.168.1.81

