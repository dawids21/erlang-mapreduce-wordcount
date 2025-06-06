# Erlang MapReduce
## Aplikacja serwerowa
Aplikację najłatwiej uruchomić za pomocą narzędzia Docker.
W celu uruchomienia aplikacji serwerowej należy utworzyć w obecnym katalogu folder `tmp`, a następnie wywołać komendę:
```sh
docker run -d \
    --network host \
    -v $PWD/tmp/$NAME:/app/node \
    -v $PWD/tmp/public:/app/public \
    -e NAME=$NAME \
    -e KNOWN_NODES=$KNOWN_NODES \
    -e COOKIE=cookie \
    --name $NAME \
    public.ecr.aws/v4e3t3o3/mapreduce/erlangmapreduce:latest
```
gdzie:
  - `NAME` - nazwa danej instancji (ważna, jeżeli testowane jest przetwarzanie na więcej niż jednym węźle),
  - `KNOWN_NODES` - lista instancji aplikacji dla przetwarzania na więcej niż jednym węźle w postaci `NAME_1@IP_1,NAME_2@IP_2`.

Testowanie przetwarzania na więcej niż jednym węźle może być wykonane na tej samej maszynie i z wykorzystaniem adresu `localhost`.

## Podłączenie do CLI
W tym celu również należy wykorzystać narzędzie Docker:
```sh
docker exec -it \
    $NAME \
    /app/bin/mapreduce_wordcount \
    remote_console
```
gdzie `NAME` to nazwa instancji do której chcemy się podłączyć.

Następnie można wydawać polecenia:
  - `{ok, Id} = mapreduce_server:start_processing(mapreduce_wordcount_mapper, mapreduce_wordcount_reducer, "examples", "output").`,
  - `mapreduce_server:check_processing(Id).`.

Ścieżki do plików należy podawać relatywnie do katalogu `$PWD/tmp/public`.
