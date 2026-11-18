
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class PathController {

    private final PathService service;

    public PathController(PathService service) {
        this.service = service;
    }

    @GetMapping("/path")
    public PathResponse shortestPath(
            @RequestParam("from") long from,
            @RequestParam("to") long to) {

        return service.findPath(from, to);
    }
}
