#[derive(Debug)]
enum ProcessAError {
    DBError(DatabaseError),
}

#[derive(Debug)]
enum DatabaseError {
    ConnectionError(String),
}

fn main() {
    println!("helloWorld");
    let err = process_a();
    println!("----");
    println!("{:?}", err);
    println!("----");

    //non_orm();
}

// Fromトレイトを使った型変換(末尾?で自動的に変換される)
impl From<DatabaseError> for ProcessAError {
    fn from(from: DatabaseError) -> ProcessAError {
        match from {
            DatabaseError::ConnectionError(_) => ProcessAError::DBError(from),
        }
    }
}
fn process_a() -> Result<(), ProcessAError> {
    fail()?;
    Ok(())
}
fn fail() -> Result<(), DatabaseError> {
    Err(DatabaseError::ConnectionError("Hello".to_string()))
}





// ORMなし
// enumとかは使ってない
// host=host1,host2,host3 port=1234,,5678 user=postgres target_session_attrs=read-write
fn non_orm() {
    let params = "host=localhost,localhost port=5432,5433 user=hoge-user password=hoge-pass dbname=hoge-db connect_timeout=10";
    let tls_mode = postgres::NoTls;
    let mut client = postgres::Client::connect(params, tls_mode);
    let mut client = match client {// 末尾?を使わないのは処理を確認するため
        Ok(client) => {
            println!("yay");
            client
        }
        Err(error) => {
            println!("{:?}", error);
            panic!("DBに接続できなかったので、panicします");
        }
    };

    let query = "SELECT users.id, users.name, users.email, users.created_at, users.updated_at FROM users";
    let params = &[];
    let rows = client.query(query, params);
    let rows = match rows {
        Ok(rows) => {
            println!("yay2");
            rows
        },
        Err(error) => {
            println!("{:?}", error);
            panic!("selectに失敗したのでpanicします");
        }
    };
    println!("----------------------[SELECT結果]");
    // https://docs.rs/postgres/0.19.1/postgres/types/trait.FromSql.html
    for row in rows {
        println!("{:?}", row);
        let id: i64 = row.get("id");
        let name: String = row.get("name");
        let email: String = row.get("email");
        let created_at: chrono::DateTime<chrono::Utc> = row.get("created_at");
        let updated_at: chrono::DateTime<chrono::Utc> = row.get("updated_at");
        println!("id: {}, name: {}, email: {}, created_at: {:?}, updated_at: {:?}", id, name, email, created_at, updated_at);
    }
}