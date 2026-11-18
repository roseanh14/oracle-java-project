
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import java.util.List;

@RestController
@RequestMapping("/api/vertices")
public class VertexController {

    private final VertexService service;

    public VertexController(VertexService service) {
        this.service = service;
    }

    @GetMapping("/nearest")
    public List<VertexResponse> nearest(
            @RequestParam double lat,
            @RequestParam double lon) {

        return service.findNearest(lat, lon);
    }
}
