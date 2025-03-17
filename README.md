## GET method
```swift
import NetworkManagerFramework

final class MyClass {
  private let fetchService: NetworkServiceProtocol
  
  init(fetchService: NetworkServiceProtocol = NetworkService()) {
    self.fetchService = fetchService
    
    fetchData()
  }
  
  func fetchData() {
    Task {
      do {
        try await fetchRequest()
      } catch {
        print(error.localizedDescription)
      }
    }
  }
  
  private func fetchRequest() async throws {
    let api = "https://jsonplaceholder.typicode.com/users"
    
    let response: [User] = try await fetchService.fetchData(urlString: api, headers: nil)
    print(response)
  }

// or fetch service with headers

private func fetchRequest() async throws {
    let api = "https://jsonplaceholder.typicode.com/users"
    let headers = ["Authorization": "Bearer \(token)"]
    
    let response: [User] = try await fetchService.fetchData(urlString: api, headers: headers)
    print(response)
  }
}
```
## GET method with headers
```swift
private func fetchRequest() async throws {
    let api = "https://jsonplaceholder.typicode.com/users"
    let headers = ["Authorization": "Bearer \(token)"]
    
    let response: [User] = try await fetchService.fetchData(urlString: api, headers: headers)
    print(response)
  }
}
```


## POST method
```swift
import NetworkManagerFramework

final class MyClass {
  private let postService: PostServiceProtocol
  
  init(postService: PostServiceProtocol = PostService()) {
    self.postService = postService
  }
  
  func login() {
    Task {
      do {
        try await requestLogin()
      } catch {
        print(error.localizedDescription)
      }
    }
  }
  
  private func requestLogin() async throws {
    let api = EndpointsEnum.loginEndpoint.rawValue
    let body = LoginModel(email: "test@email.com", password: "testPassword")
    
    let response: loginResponse = try await postService.postData(urlString: api, headers: nil, body: body)
    print(response)
  }
}
```
