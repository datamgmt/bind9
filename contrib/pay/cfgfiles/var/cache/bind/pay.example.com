$TTL 1d
$ORIGIN example.com.

@       PAY     SOA     ns1 root (
                2019122502      ;serial
                12h             ;refresh
                15m             ;retry
                3w              ;expire
                2h              ;minimum
        )

@		NS	ns1

payex   PAY	TXT     "This is a payments record"
payex   PAY	ACCOUNT 10 payment.bank.com.
