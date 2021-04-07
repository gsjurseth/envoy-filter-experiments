# envoy-filter-experiments
Have you ever thought that it would be great if there were a couple of envoy 
examples that used LUA to do something real and began to at least approach
what might be considered a realistic use case?

This repo aims to show:
* Inline lua examples that execute on every request
* Lua examples that use the LuaPerRoute setup to execute on specific routes
* Included lua addons to extend the base functaionlity
* A simple translation that converts xml->json and then json->xml if the 
appropriate headers are set
* A library that's referenced from the code so that everything isn't embedded
as a monster inside the `envoy.yaml` file.
* A simple docker-compose setup to make it all work

## Run it
So checkout this repo and then run:

```bash
docker-compose build && docker-compose up
```

That's it. If you'd like to turn on debug logging then edit the docker
composition and change: LOGLEVEL to `debug`

```yaml
  proxy:
    build:
      context: .
      dockerfile: ./Dockerfile-envoy
    environment:
      LOGLEVEL: "debug"
```

Once it's up you can test it

## Testing it
Running the following will send a get request to `httpbin.org` and then add
a new header called `X-Apigee-Bar` which is just a dynamic copy of the user-agent.

Run it like so:

```bash
 docker exec -it envoy-filter-experiments_proxy_1 curl http://localhost:10000/get
 ```
 which should yield something like:
 ```json
 {
  "args": {},
  "headers": {
    "Accept": "*/*",
    "Host": "httpbin.org",
    "User-Agent": "curl/7.58.0",
    "X-Amzn-Trace-Id": "Root=1-606de78c-1e4a4e15124016f82293e01f",
    "X-Apigee-Bar": "curl/7.58.0",
    "X-Envoy-Expected-Rq-Timeout-Ms": "15000"
  },
  "origin": "1.2.3.4",
  "url": "http://httpbin.org/get"
}
 ```

 If you'd like to test a post and a dynamic conversion of xml -> json then then back
 again run something like this:

```
docker exec -it envoy-filter-experiments_proxy_1 curl -i http://localhost:10000/post -X POST -d '<xml><foo>bar</foo></xml>' -H "content-type: application/xml" -H "Accept: application/xml"
```
Which yields:
```xml
<body>
  <args>

  </args>
  <origin>1.2.3.4</origin>
  <url>http://httpbin.org/post</url>
  <headers>
        <X-Envoy-Expected-Rq-Timeout-Ms>15000</X-Envoy-Expected-Rq-Timeout-Ms>
        <User-Agent>curl/7.58.0</User-Agent>
        <X-Amzn-Trace-Id>Root=1-606de87f-49b9391d5ad7c47928347487</X-Amzn-Trace-Id>
        <Content-Length>21</Content-Length>
        <Content-Type>application/json</Content-Type>
        <Accept>application/xml</Accept>
        <Host>httpbin.org</Host>
  </headers>
  <data>{"xml":{"foo":"bar"}}</data>
  <json>
          <xml>
              <foo>bar</foo>
          </xml>
  </json>
  <files>

  </files>
  <form>

  </form>
</body>
```

Running it with an accept header of `appliation/json` will keep it all in json as expected.
```
docker exec -it envoy-filter-experiments_proxy_1 curl -i http://localhost:10000/post -X POST -d '<xml><foo>bar</foo></xml>' -H "content-type: application/xml" -H "Accept: application/json"
```
And yields:
```json
{
  "args": {},
  "data": "{\"xml\":{\"foo\":\"bar\"}}",
  "files": {},
  "form": {},
  "headers": {
    "Accept": "application/json",
    "Content-Length": "21",
    "Content-Type": "application/json",
    "Host": "httpbin.org",
    "User-Agent": "curl/7.58.0",
    "X-Amzn-Trace-Id": "Root=1-606de89e-5805b64047517ba04082bd9a",
    "X-Envoy-Expected-Rq-Timeout-Ms": "15000"
  },
  "json": {
    "xml": {
      "foo": "bar"
    }
  },
  "origin": "1.2.3.4",
  "url": "http://httpbin.org/post"
}
```

## What's next
We could obviously do a lot more, but I think this repo shows it's possible to build real,
body-touching examles with envoy that shoudld be able to accomplish at least simple
mediation.
