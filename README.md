<div align="center">
<h1>chompy</h1>
<h3>the resilient dom viewer</h3>
<img src="https://github.com/brettshollenberger/chompy/blob/master/lib/assets/img/hipsterchompy.gif">
</div>

### Fault Tolerance is a Requirement, Not A Feature

Chompy displays the source code of web pages resiliently. Since the system could receive a request to display literally any page, a DOM viewer could be susceptible to a number of tricky bugs: long running network calls, servers returning unintelligible formats, malicious users that direct traffic to servers that intentionally hang forever.

The Netflix Tech Blog has pointed to systems of theirs that have some 30 dependencies a piece--and without taking steps for fault tolerance, systems with 30 dependencies with 99.99% uptime would still have more than 2 hours of downtime per month (99.99^30 = 99.7% uptime = 2+ hours in a month). Chompy has a nearly infinite number of dependencies (any page on the internet), and as such it is designed for aggressive fault tolerance.

### What is Fault Tolerance?

A fault tolerant application plans for its own failure, and rebounds from failures by providing users with a degraded experience. In an intolerant application, users would come to understand that the system had failed passively--they would see no indication that their request had been received, or that it had failed; they would only see that nothing happened. They didn't see the source code they requested. 

An intolerant system would not only fail to acknowledge requests and failures, it would also be easy prey for attack. The API could easily be flooded with requests, or requests to long-running servers; if the API requested external resources as part of the request/response cycle, with no knowledge of the requests it was making, no timeouts, no parallelism, and no overarching failure management system (like a circuit breaker)--it would fail easily and fail hard.

### What Does the User See?

In the best case scenario, the user sees that everything is working as expected. They request a webpage's source code, and see it displayed nearly instantaneously. 

If the source code takes a little over half a second in the backend, the user receives acknowledgement that their request has been received via a notification. If the code has already been displayed, the user will never see this notification, since the user already has what they wanted.

If the backend takes even longer (a few seconds), it cuts off the long-running request, and acknowledges to the user that it has made a failed attempt, and that it is trying again. After three failed attempts to retrieve the source code, Chompy alerts the user that the request will not process at this time, and terminates execution. 

Chompy opts for degraded experience first, and moves to an improved experience if possible. Upon first receipt of the source code, Chompy presents it instantly to the user, highlights the code outside of the DOM, and then improves the UX by inserting the highlighted code.

### How Does Chompy Achieve This?

* Network timeouts and retries
* Threaded, worker-based remote calls
* Circuit breakers

Chompy uses web sockets to receive requests, and places requests on a queue for workers to consume at their speed. As workers make attempts to process requests, they send success and failure information over Redis pub/sub to the requesting socket to return to the client. 

The remote requests are wrapped in circuit breaker objects to manage timeouts and failure rates. If requests run too long, they are terminated, logged, and failure information is returned to the client. The circuit breaker maintains these failure logs, and if the breaker reaches a certain failure threshold (90%), it stops processing external requests--returning immediate failures while it recovers. 

This very high threshold is appropriate for an application like Chompy, where its dependencies are unknown. In an application like Netflix, where the 30-some dependencies are known, in-house APIs, circuit breakers manage the state of individual dependencies, and set significantly lower thresholds, since persistant failure tends to indicate that the remote service is unavailable. In an application like Chompy, persistent failure would indicate instead that Chompy was experiencing networking failures itself, or that malicious users were flooding the application, because many more requests were failing than expected (normal requests would be expected to succeed). 

Chompy's backend is also aggressive about error recovery--recognizing errors from HTTP status codes, poorly formed user requests, buffering errors, encoding errors, and network latency. It does everything it can to understand the user's request and server's response, but is still likely subject to yet unknown errors that would need to be built in as they are uncovered. 

### Client Resiliency Matters, Too

By default, web sockets do not chunk messages the way HTTP does. Since the Chompy client reads potentially massive source code responses and places them in the DOM, the Chompy server chunks web socket responses so the client can begin processing them as soon as possible. 

The client uses functional reactive programming (the RxJS library), to assemble streaming responses and insert them into the DOM, or apply them as user notifications. The first step in DOM directives is usually a socket filter, so that the component only pays attention to messages in which it is interested. 

Syntax highlight is, if possible, achieved asynchronously via Web Workers, and outside of the DOM, so that the user can first view unhighlighted code, and then proceed to an improved experience as it becomes available. 
