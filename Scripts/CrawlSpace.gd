extends Area2D
class_name CrawlSpace

export(bool) var enabled = true

func _on_CrawlSpace_body_entered(body:Node):
	if enabled:
		if body.is_in_group("Player"):
			body.attempt_crawl()

func _on_CrawlSpace_body_exited(body:Node):
	if enabled:
		if body.is_in_group("Player"):
			body.attempt_un_crawl()