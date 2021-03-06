output "ecs_cluster_id" {
  value = aws_ecs_cluster.cluster.id
}

output "ecs_cluster_name" {
  value = local.name
}

output "ecs_cluster_sg" {
  value = aws_security_group.instance_default_sg.id
}

// output "alb_arn" {
//   value = "${aws_alb.alb.arn}"
// }
//
// output "alb_listener_arns" {
//   value = [
//     "${aws_alb_listener.http.arn}",
//     "${aws_alb_listener.https.arn}",
//   ]
// }
