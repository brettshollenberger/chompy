<div align="center">
<h1>chompy</h1>
<img src="https://github.com/brettshollenberger/chompy/blob/master/lib/assets/img/hipsterchompy.gif">
</div>

### Resilient DOM Viewer

Chompy displays the source code of web pages resiliently. It queues requests & deals with network failures quickly without blocking the remaining jobs. It uses a circuit breaker pattern to shut down failing remote requests temporarily, and features a built-in chaos monkey to simulate network outages at varying degrees. 
