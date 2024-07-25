import Vapor
import Redis

struct RedisConfig {
    let host: String
    let port: Int
}

final class RedisClientApp {
    
    let app: Application
    let redisConfig: RedisConfig
    
    init(
        redisConfig: RedisConfig = RedisConfig(host: "localhost", port: 55003) // Official redis server
    ) throws {
        self.redisConfig = redisConfig
        self.app = Application(.testing)
        try configure(app)
    }
    
    func run() throws {
        defer { app.shutdown() }
        try app.run()
    }
    
    func shutdown() {
        app.shutdown()
    }
    
    func configure(_ app: Application) throws {
        app.redis.configuration = try RedisConfiguration(
            hostname: redisConfig.host,
            port: redisConfig.port
        )
        
        try routes(app)
    }
    
    func routes(_ app: Application) throws {
        app.get("ping") { req -> EventLoopFuture<String> in
            req.redis.send(command: "PING").map { resp in
                return resp.string ?? "Error"
            }
        }
        
        app.get("set", ":key", ":value") { req -> EventLoopFuture<String> in
            let key = req.parameters.get("key")!
            let value = req.parameters.get("value")!
            return req.redis.set(.init(key), to: value).map { "OK" }
        }
        
        app.get("get", ":key") { req -> EventLoopFuture<String> in
            let key = req.parameters.get("key")!
            return req.redis.get(.init(key), as: String.self).map { value in
                return value ?? "nil"
            }
        }
    }
}
