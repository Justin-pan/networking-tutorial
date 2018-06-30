//
//  networkingAPI.swift
//  networking tutorial
//
//

import Foundation

//codeable post for retrieving JSON info from a REST API
//codeable protocol is a type that can convert itself into and out of an external representation
struct Post: Codable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

//enumeration defines common type for a group of related values and enables you to work with those values in a type safe way
//in this case, the enum describes cases of a result (success, failure) with a value
enum Result<Value> {
    case success(Value)
    case failure(Error)
}

//function for getting posts with HTTP get request
func getPosts(for userId: Int, completion: ((Result<[Post]>) -> Void)?) {
    //Creating the url which will be used for the GET request
    var urlComponents = URLComponents()
    //request scheme
    urlComponents.scheme = "https"
    //request host
    urlComponents.host = "jsonplaceholder.typicode.com"
    //request path
    urlComponents.path = "/posts"
    //the query for in the url for the get request, in the order of the original query string, name-value pair
    let userIdItem = URLQueryItem(name: "userId", value: "\(userId)")
    //urls query items
    urlComponents.queryItems = [userIdItem]
    //create the url, guard used for maintainability, transfers program control out of scope if conditions not met
    guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
    
    //create the request
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    //configurations for the URLSession
    let config = URLSessionConfiguration.default
    let session = URLSession(configuration: config)
    //sending the request and dealing with the response
    let task = session.dataTask(with: request) { (responseData, response, responseError) in
        DispatchQueue.main.async {
            if let error = responseError {
                completion?(.failure(error))
            } else if let jsonData = responseData {
                // Now we have jsonData, Data representation of the JSON returned to us
                // from our URLRequest...
                
                // Create an instance of JSONDecoder to decode the JSON data to our
                // Codable struct
                let decoder = JSONDecoder()
                
                do {
                    // We would use Post.self for JSON representing a single Post
                    // object, and [Post].self for JSON representing an array of
                    // Post objects
                    let posts = try decoder.decode([Post].self, from: jsonData)
                    completion?(.success(posts))
                } catch {
                    completion?(.failure(error))
                }
            } else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Data was not retrieved from request"]) as Error
                completion?(.failure(error))
            }
        }
    }
    
    task.resume()
}
//completion block that returns an error if something goes wrong
func submitPost(post: Post, completion: ((Error?) -> Void)?) {
    //Creating the url which will be used for the GET request
    var urlComponents = URLComponents()
    //request scheme
    urlComponents.scheme = "https"
    //request host
    urlComponents.host = "jsonplaceholder.typicode.com"
    //request path
    urlComponents.path = "/posts"
    //create the url, guard used for maintainability, transfers program control out of scope if conditions not met
    guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
    //create post request with the created url
    var request = URLRequest(url: url)
    //post http method
    request.httpMethod = "POST"
    //request headers
    var headers = request.allHTTPHeaderFields ?? [:]
    //header is Content-Type and application/json
    headers["Content-Type"] = "application/json"
    //the request made has these headers/
    //these headers will let the server know that the request body is JSON encoded
    request.allHTTPHeaderFields = headers
    //instantiating the encoder
    let encoder = JSONEncoder()
    do{
        let jsonData = try encoder.encode(post)
        request.httpBody = jsonData
        //set httprequest body
        print("jsonData: ", String(data: request.httpBody!, encoding: .utf8) ?? "no body data")
        
    }catch{
        completion?(error)
    }
    let config = URLSessionConfiguration.default
    let session = URLSession(configuration: config)
    //URL session data task with the request made
    let task = session.dataTask(with: request){ (responseData, response, responseError) in
        guard responseError == nil else{
            completion?(responseError!)
            return
        }
        //API's usually respond with the data you sent
        if let data = responseData, let utf8Representation = String(data: data, encoding: .utf8) {
            print("response: ", utf8Representation)
        }else{
            print("No readable data recieved in response")
        }
    }
    task.resume()
}


// Helper method to get a URL to the user's documents directory
// see https://developer.apple.com/icloud/documentation/data-storage/index.html
func getDocumentsURL() -> URL {
    if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
        return url
    } else {
        fatalError("Could not retrieve documents directory")
    }
}

func savePostsToDisk(posts: [Post]) {
    // 1. Create a URL for documents-directory/posts.json
    let url = getDocumentsURL().appendingPathComponent("posts.json")
    // 2. Endcode our [Post] data to JSON Data
    let encoder = JSONEncoder()
    do {
        let data = try encoder.encode(posts)
        // 3. Write this data to the url specified in step 1
        try data.write(to: url, options: [])
    } catch {
        fatalError(error.localizedDescription)
    }
}

func getPostsFromDisk() -> [Post] {
    // 1. Create a url for documents-directory/posts.json
    let url = getDocumentsURL().appendingPathComponent("posts.json")
    let decoder = JSONDecoder()
    do {
        // 2. Retrieve the data on the file in this path (if there is any)
        let data = try Data(contentsOf: url, options: [])
        // 3. Decode an array of Posts from this Data
        let posts = try decoder.decode([Post].self, from: data)
        return posts
    } catch {
        fatalError(error.localizedDescription)
    }
}
