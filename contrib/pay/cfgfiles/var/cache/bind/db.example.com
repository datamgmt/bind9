$TTL 1d
$ORIGIN example.com.

@       IN      SOA     ns1 root (
                2019122502      ;serial
                12h             ;refresh
                15m             ;retry
                3w              ;expire
                2h              ;minimum
        )

@       IN      A       10.0.2.15

@       IN      NS      ns1
ns1     IN      A       10.0.2.15

@       IN      NS      ns2.example.com.
ns2     IN      A       10.0.2.16

@       IN      MX      10      mail
mail    IN      A       10.0.2.15

www     IN      A       10.0.2.15


;davidw PAY     CR      123456789
