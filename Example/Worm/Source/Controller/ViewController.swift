//
//  ViewController.swift
//  Worm
//
//  Created by wbitos on 01/07/2022.
//  Copyright (c) 2022 wbitos. All rights reserved.
//

import UIKit
import Worm

class ViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    
    var articles: [Article] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        Article.migrate()
        self.articles = Article.all()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func addArticle(_ sender: Any?) {
        let article = Article()
        article.title = "我是文章\(arc4random())"
        article.desc = "我是内容\(arc4random())"
        article.images = []
        article.url = "https://www.wbitos.com/article/\(arc4random())"
        article.createdAt = Date()
        article.updatedAt = Date()
        article.insert()
        
        self.articles = Article.all()
        self.tableView.reloadData()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let articleCell = tableView.dequeueReusableCell(withIdentifier: "ArticleTableCell", for: indexPath) as? ArticleTableCell else {
            return UITableViewCell()
        }
        let article = self.articles[indexPath.row]
        articleCell.textLabel?.text = article.title
        articleCell.detailTextLabel?.text = article.desc
        return articleCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let article = self.articles[indexPath.row]
        NSLog("did select: \(article.id) - \(article.title)")
    }
}

